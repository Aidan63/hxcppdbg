package hxcppdbg.dap;

import cpp.asio.streams.IReadStream;
import cpp.asio.streams.IWriteStream;
import cpp.asio.Result;
import haxe.Exception;
import hxcppdbg.core.Session;
import sys.thread.Thread;
import cpp.asio.Code;
import cpp.asio.TcpSocket;

class Dap
{
    var server : TcpSocket;

    final clients : Array<TcpClient>;

    public var mode : String;

    public var target : String;

    public var sourcemap : String;

    public function new()
    {
        server    = null;
        clients   = [];

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
                clients.push(client);

                startDebugSession(client.stream, client.stream);
            case Error(code):
                trace('failed to connect client : $code');
        }
    }

    function noop()
    {
        //
    }

    function startDebugSession(_input : IReadStream, _output : IWriteStream)
    {
        final thread    = Thread.createWithEventLoop(() -> new Session(target, sourcemap));
        final heartbeat = thread.events.repeat(noop, 1000);
        final dap       = new DapSession(thread.events, _input, _output, () -> {
            for (client in clients)
            {
                client.shutdown(result -> {
                    switch result
                    {
                        case Some(v):
                            trace(v);
                        case None:
                            trace('now closing');
                            client.close();
                    }
                });
            }
        });
    }
}
