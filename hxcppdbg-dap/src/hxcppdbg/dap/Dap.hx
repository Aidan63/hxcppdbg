package hxcppdbg.dap;

import cpp.vm.Gc;
import sys.thread.EventLoop.EventHandler;
import cpp.asio.streams.IReadStream;
import cpp.asio.streams.IWriteStream;
import cpp.asio.Result;
import haxe.Exception;
import hxcppdbg.core.Session;
import sys.thread.Thread;
import cpp.asio.Code;
import cpp.asio.TcpSocket;

using hxrx.observables.Observables;

class Dap
{
    var server : TcpSocket;

    public var mode : String;

    public var target : String;

    public var sourcemap : String;

    public function new()
    {
        server    = null;
        mode      = 'stdio';
        target    = '';
        sourcemap = '';
    }

    @:defaultCommand
    public function run()
    {
        switch mode
        {
            case 'stdio':
                //
            case 'socket':
                trace('starting socket');

                cpp.asio.TcpSocket.bind('127.0.0.1', 7777, onSocketListen);
            case other:
                throw new Exception('unknown mode $other');
        }
    }

    @:command
    public function help()
    {
        //
    }

    function onSocketListen(_result : Result<TcpSocket, Code>)
    {
        switch _result
        {
            case Success(socket):
                server = socket;

                socket.listen(onConnectionRequest);
            case Error(code):
                trace('failed to bind to address : $code');
        }
    }

    function onConnectionRequest(_result : Result<TcpRequest, Code>)
    {
        switch _result
        {
            case Success(request):
                trace('connection request');

                request.accept(onClientConnected);
            case Error(code):
                trace('failed to listen for connection requests : $code');
        }
    }

    function onClientConnected(_result : Result<TcpClient, Code>)
    {
        switch _result
        {
            case Success(client):
                startDebugSession(target, sourcemap, client);
            case Error(code):
                trace('failed to connect client : $code');
        }
    }

    static function noop()
    {
        //
    }

    static function startDebugSession(_target : String, _sourcemap : String, _client : TcpClient)
    {
        var session : Session;
        var heartbeat : EventHandler;

        final main   = Thread.current();
        final thread = Thread.createWithEventLoop(() -> {
            session   = new Session(_target, _sourcemap);
            heartbeat = Thread.current().events.repeat(noop, 1000);
        });

        final dap       = new DapSession(_client.stream, _client.stream);
        final scheduler = new ThreadEventsScheduler(main.events);

        dap
            .onLaunch
            .observeOn(scheduler)
            .subscribeFunction(_ -> {
                switch session.start()
                {
                    case Success(reason):
                        switch reason
                        {
                            case ExceptionThrown(_thread):
                                main.events.run(() -> dap.sendExceptionThrown(_thread));
                            case BreakpointHit(_id, _thread):
                                main.events.run(() -> dap.sendBreakpointHit(_id, _thread));
                            case Paused:
                                main.events.run(dap.sendPaused);
                            case Natural:
                                main.events.run(dap.sendExited);
                        }
                    case Error(e):
                        trace(e.message);
                }
            });

        dap
            .onDisconnect
            .observeOn(scheduler)
            .subscribeFunction(_ -> {
                switch session.stop()
                {
                    case Some(v):
                        trace(v.message);
                    case None:
                        //
                }

                thread.events.cancel(heartbeat);

                _client.shutdown(result -> {
                    switch result
                    {
                        case Some(v):
                            trace(v);
                        case None:
                            _client.close();
                    }
                });
            });

        dap
            .onPause
            .observeOn(scheduler)
            .subscribeFunction(_ -> {
                switch session.pause()
                {
                    case Some(v):
                        trace(v);
                    case None:
                        //
                }
            });
    }
}
