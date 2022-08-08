package hxcppdbg.dap;

import tink.CoreApi.Noise;
import tink.CoreApi.Error;
import tink.CoreApi.Promise;
import sys.thread.EventLoop.EventHandler;
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
    public var mode : String;

    public var target : String;

    public var sourcemap : String;

    public function new()
    {
        mode      = 'stdio';
        target    = '';
        sourcemap = '';
    }

    @:defaultCommand
    public function run()
    {
        return Promise.irreversible((_resolve : Noise->Void, _reject : Error->Void) -> {
            switch mode
            {
                case 'socket':
                    cpp.asio.TcpSocket.bind('127.0.0.1', 7777, onSocketListen.bind(_reject));
                case other:
                    _reject(new Error('unknown mode $other'));
            }
        });
    }

    @:command
    public function help()
    {
        //
    }

    function onSocketListen(_reject : Error->Void, _result : Result<TcpSocket, Code>)
    {
        switch _result
        {
            case Success(socket):
                socket.listen(onConnectionRequest.bind(_reject));
            case Error(code):
                _reject(new Error('failed to bind to address : $code'));
        }
    }

    function onConnectionRequest(_reject : Error->Void, _result : Result<TcpRequest, Code>)
    {
        switch _result
        {
            case Success(request):
                request.accept(onClientConnected);
            case Error(code):
                _reject(new Error('failed to listen for connection requests : $code'));
        }
    }

    function onClientConnected(_result : Result<TcpClient, Code>)
    {
        switch _result
        {
            case Success(client):
                startDebugSession(target, sourcemap, client);
            case Error(code):
                Sys.println('failed to connect client : $code');
        }
    }

    static function startDebugSession(_target : String, _sourcemap : String, _client : TcpClient)
    {
        final session = new Session(_target, _sourcemap);
        final dap     = new DapSession(_client.stream, _client.stream);

        dap.onLaunch.subscribe(sequence -> {
            session.start(result -> {
                switch result
                {
                    case Success(run):
                        dap.sendResponse(sequence, 'launch', DapResponse.Success);

                        run(result -> {
                            switch result
                            {
                                case Success(None):
                                    dap.sendExited();
                                case Success(Some(interrupt)):
                                    switch interrupt
                                    {
                                        case ExceptionThrown(threadIndex):
                                            dap.sendExceptionThrown(threadIndex);
                                        case BreakpointHit(threadIndex, id):
                                            dap.sendBreakpointHit(threadIndex, id);
                                        case Other:
                                            //
                                    }
                                case Error(exn):
                                    //
                            }
                        });
                    case Error(exn):
                        dap.sendResponse(sequence, 'launch', DapResponse.Failure(exn));
                }
            });
        });

        dap.onPause.subscribe(sequence -> {
            session.pause(result -> {
                switch result
                {
                    case Success(paused):
                        dap.sendResponse(sequence, 'pause', DapResponse.Success);
                        dap.sendPaused();
                    case Error(exn):
                        dap.sendResponse(sequence, 'pause', DapResponse.Failure(exn));
                }
            });
        });

        dap.onDisconnect.subscribe(sequence -> {
            session.stop(result -> {
                switch result
                {
                    case Some(exn):
                        dap.sendResponse(sequence, 'disconnect', DapResponse.Failure(exn));
                    case None:
                        dap.sendResponse(sequence, 'disconnect', DapResponse.Success);
                }
            });
        });
    }
}
