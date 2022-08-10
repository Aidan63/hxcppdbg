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

using Lambda;

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

        dap.onLaunch.subscribe(data -> {
            session.start(result -> {
                switch result
                {
                    case Success(run):
                        dap.sendResponse(data.sequence, 'launch', DapResponse.Success(null));

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
                                    dap.sendPaused();
                            }
                        });
                    case Error(exn):
                        dap.sendResponse(data.sequence, 'launch', DapResponse.Failure(exn));
                }
            });
        });

        dap.onPause.subscribe(sequence -> {
            session.pause(result -> {
                switch result
                {
                    case Success(_):
                        dap.sendResponse(sequence, 'pause', DapResponse.Success(null));
                        dap.sendPaused();
                    case Error(exn):
                        dap.sendResponse(sequence, 'pause', DapResponse.Failure(exn));
                }
            });
        });

        dap.onContinue.subscribe(sequence -> {
            session.resume(result -> {
                switch result {
                    case Success(run):
                        dap.sendResponse(sequence, 'continue', DapResponse.Success({ allThreadsContinued : true }));

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
                                    dap.sendPaused();
                            }
                        });
                    case Error(exn):
                        dap.sendResponse(sequence, 'continue', DapResponse.Failure(exn));
                }
            });
        });

        dap.onStackTrace.subscribe(message -> {
            session.stack.getCallStack(message.arguments.threadId, result -> {
                switch result
                {
                    case Success(frames):
                        dap.sendResponse(
                            message.seq,
                            'stackTrace',
                            DapResponse.Success({
                                totalFrames : frames.length,
                                stackFrames : frames.mapi((idx, frame) -> {
                                    final id  = new FrameId(message.arguments.threadId, idx);

                                    switch frame
                                    {
                                        case Haxe(haxe, native):
                                            {
                                                id               : id,
                                                name             : switch haxe.closure {
                                                    case Some(closure):
                                                        '${ haxe.file.type }.${ haxe.func.name }.${ closure.name }()';
                                                    case None:
                                                        '${ haxe.file.type }.${ haxe.func.name }()';
                                                },

                                                line             : haxe.expr.haxe.start.line,
                                                endLine          : haxe.expr.haxe.end.line,

                                                column : haxe.expr.haxe.start.col,
                                                endColumn : haxe.expr.haxe.end.col,

                                                presentationHint : 'normal',
                                                source : {
                                                    name : haxe.func.name,
                                                    path : haxe.file.haxe
                                                },
                                                sources : [
                                                    {
                                                        name : native.func,
                                                        path : native.file
                                                    }
                                                ]
                                            }
                                        case Native(native):
                                            {
                                                id               : id,
                                                name             : '[native] ${ native.func }',
                                                line             : native.line,
                                                column           : 0,
                                                presentationHint : 'subtle',
                                                source : {
                                                    name : native.func,
                                                    path : native.file
                                                }
                                            }
                                    }
                                })
                            }));
                    case Error(exn):
                        dap.sendResponse(message.seq, 'stackTrace', DapResponse.Failure(exn));
                }
            });
        });

        dap.onThreads.subscribe(sequence -> {
            session.pause(result -> {
                switch result
                {
                    case Success(paused):
                        session.threads.getThreads(response -> {
                            switch response
                            {
                                case Success(threads):
                                    dap.sendResponse(sequence, 'threads', DapResponse.Success({
                                        threads : threads.map(t -> { id : t.index, name : t.name })
                                    }));
                                case Error(exn):
                                    dap.sendResponse(sequence, 'threads', DapResponse.Failure(exn));
                            }

                            if (paused)
                            {
                                //

                                session.resume(result -> {
                                    switch result
                                    {
                                        case Success(run):
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
                                                        dap.sendPaused();
                                                }
                                            });
                                        case Error(exn):
                                            dap.sendPaused();
                                    }
                                });
                            }
                        });
                    case Error(exn):
                        dap.sendResponse(sequence, 'threads', DapResponse.Failure(exn));
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
                        dap.sendResponse(sequence, 'disconnect', DapResponse.Success(null));
                }

                _client.close();
            });
        });
    }
}
