package hxcppdbg.dap;

import tink.CoreApi.Noise;
import tink.CoreApi.Error;
import tink.CoreApi.Promise;
import sys.thread.EventLoop.EventHandler;
import cpp.asio.streams.IReadStream;
import cpp.asio.streams.IWriteStream;
import cpp.asio.Result;
import haxe.Exception;
import haxe.ds.Option;
import hxcppdbg.core.Session;
import sys.thread.Thread;
import cpp.asio.Code;
import cpp.asio.TcpSocket;

using Lambda;

class Dap
{
    public var mode : String;

    public function new()
    {
        mode = 'stdio';
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

    static function onSocketListen(_reject : Error->Void, _result : Result<TcpSocket, Code>)
    {
        switch _result
        {
            case Success(socket):
                socket.listen(onConnectionRequest.bind(_reject));
            case Error(code):
                _reject(new Error('failed to bind to address : $code'));
        }
    }

    static function onConnectionRequest(_reject : Error->Void, _result : Result<TcpRequest, Code>)
    {
        switch _result
        {
            case Success(request):
                request.accept(onClientConnected);
            case Error(code):
                _reject(new Error('failed to listen for connection requests : $code'));
        }
    }

    static function onClientConnected(_result : Result<TcpClient, Code>)
    {
        switch _result
        {
            case Success(client):
                new DapSession(client.stream, client.stream, () -> client.close());
            case Error(code):
                Sys.println('failed to connect client : $code');
        }
    }

    // static function launchDebugee(_client : TcpClient, _dap : DapSession, _data : { sequence : Int, program : String, sourcemap : String })
    // {
    //     final session = new Session(_data.program, _data.sourcemap);

    //     session.start(result -> {
    //         switch result
    //         {
    //             case Success(run):
    //                 _dap.sendResponse(_data.sequence, 'launch', DapResponse.Success(null));

    //                 run(result -> {
    //                     switch result
    //                     {
    //                         case Success(None):
    //                             _dap.sendExited();
    //                         case Success(Some(interrupt)):
    //                             switch interrupt
    //                             {
    //                                 case ExceptionThrown(threadIndex):
    //                                     _dap.sendExceptionThrown(threadIndex);
    //                                 case BreakpointHit(threadIndex, id):
    //                                     _dap.sendBreakpointHit(threadIndex, id);
    //                                 case Other:
    //                                     //
    //                             }
    //                         case Error(exn):
    //                             _dap.sendPaused();
    //                     }
    //                 });
    //             case Error(exn):
    //                 _dap.sendResponse(_data.sequence, 'launch', DapResponse.Failure(exn));
    //         }
    //     });

    //     _dap.onPause = function(_callback : Option<Exception>->Void) {
    //         session.pause(result -> {
    //             switch result
    //             {
    //                 case Success(_):
    //                     _callback(Option.None);
    //                 case Error(exn):
    //                     _callback(Option.Some(exn));
    //             }
    //         });
    //     }

    //     _dap.onContinue.subscribe(sequence -> {
    //         session.resume(result -> {
    //             switch result {
    //                 case Success(run):
    //                     _dap.sendResponse(sequence, 'continue', DapResponse.Success({ allThreadsContinued : true }));

    //                     run(result -> {
    //                         switch result
    //                         {
    //                             case Success(None):
    //                                 _dap.sendExited();
    //                             case Success(Some(interrupt)):
    //                                 switch interrupt
    //                                 {
    //                                     case ExceptionThrown(threadIndex):
    //                                         _dap.sendExceptionThrown(threadIndex);
    //                                     case BreakpointHit(threadIndex, id):
    //                                         _dap.sendBreakpointHit(threadIndex, id);
    //                                     case Other:
    //                                         //
    //                                 }
    //                             case Error(exn):
    //                                 _dap.sendPaused();
    //                         }
    //                     });
    //                 case Error(exn):
    //                     _dap.sendResponse(sequence, 'continue', DapResponse.Failure(exn));
    //             }
    //         });
    //     });

    //     _dap.onStackTrace.subscribe(message -> {
    //         session.stack.getCallStack(message.arguments.threadId, result -> {
    //             switch result
    //             {
    //                 case Success(frames):
    //                     _dap.sendResponse(
    //                         message.seq,
    //                         'stackTrace',
    //                         DapResponse.Success({
    //                             totalFrames : frames.length,
    //                             stackFrames : frames.mapi((idx, frame) -> {
    //                                 final id  = new FrameId(message.arguments.threadId, idx);

    //                                 switch frame
    //                                 {
    //                                     case Haxe(haxe, native):
    //                                         {
    //                                             id               : id,
    //                                             name             : switch haxe.closure {
    //                                                 case Some(closure):
    //                                                     '${ haxe.file.type }.${ haxe.func.name }.${ closure.name }()';
    //                                                 case None:
    //                                                     '${ haxe.file.type }.${ haxe.func.name }()';
    //                                             },

    //                                             line             : haxe.expr.haxe.start.line,
    //                                             endLine          : haxe.expr.haxe.end.line,

    //                                             column : haxe.expr.haxe.start.col,
    //                                             endColumn : haxe.expr.haxe.end.col,

    //                                             presentationHint : 'normal',
    //                                             source : {
    //                                                 name : haxe.func.name,
    //                                                 path : haxe.file.haxe
    //                                             },
    //                                             sources : [
    //                                                 {
    //                                                     name : native.func,
    //                                                     path : native.file
    //                                                 }
    //                                             ]
    //                                         }
    //                                     case Native(native):
    //                                         {
    //                                             id               : id,
    //                                             name             : '[native] ${ native.func }',
    //                                             line             : native.line,
    //                                             column           : 0,
    //                                             presentationHint : 'subtle',
    //                                             source : {
    //                                                 name : native.func,
    //                                                 path : native.file
    //                                             }
    //                                         }
    //                                 }
    //                             })
    //                         }));
    //                 case Error(exn):
    //                     _dap.sendResponse(message.seq, 'stackTrace', DapResponse.Failure(exn));
    //             }
    //         });
    //     });

    //     _dap.onThreads.subscribe(sequence -> {
    //         session.pause(result -> {
    //             switch result
    //             {
    //                 case Success(paused):
    //                     session.threads.getThreads(response -> {
    //                         switch response
    //                         {
    //                             case Success(threads):
    //                                 _dap.sendResponse(sequence, 'threads', DapResponse.Success({
    //                                     threads : threads.map(t -> { id : t.index, name : t.name })
    //                                 }));
    //                             case Error(exn):
    //                                 _dap.sendResponse(sequence, 'threads', DapResponse.Failure(exn));
    //                         }

    //                         if (paused)
    //                         {
    //                             //

    //                             session.resume(result -> {
    //                                 switch result
    //                                 {
    //                                     case Success(run):
    //                                         run(result -> {
    //                                             switch result
    //                                             {
    //                                                 case Success(None):
    //                                                     _dap.sendExited();
    //                                                 case Success(Some(interrupt)):
    //                                                     switch interrupt
    //                                                     {
    //                                                         case ExceptionThrown(threadIndex):
    //                                                             _dap.sendExceptionThrown(threadIndex);
    //                                                         case BreakpointHit(threadIndex, id):
    //                                                             _dap.sendBreakpointHit(threadIndex, id);
    //                                                         case Other:
    //                                                             //
    //                                                     }
    //                                                 case Error(exn):
    //                                                     _dap.sendPaused();
    //                                             }
    //                                         });
    //                                     case Error(exn):
    //                                         _dap.sendPaused();
    //                                 }
    //                             });
    //                         }
    //                     });
    //                 case Error(exn):
    //                     _dap.sendResponse(sequence, 'threads', DapResponse.Failure(exn));
    //             }
    //         });
    //     });

    //     _dap.onDisconnect.subscribe(sequence -> {
    //         session.stop(result -> {
    //             switch result
    //             {
    //                 case Some(exn):
    //                     _dap.sendResponse(sequence, 'disconnect', DapResponse.Failure(exn));
    //                 case None:
    //                     _dap.sendResponse(sequence, 'disconnect', DapResponse.Success(null));
    //             }

    //             _client.close();
    //         });
    //     });
    // }
}