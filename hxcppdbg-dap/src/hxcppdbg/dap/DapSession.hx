package hxcppdbg.dap;

import hxcppdbg.dap.protocol.Event;
import hxcppdbg.dap.protocol.StackFrame;
import hxcppdbg.dap.protocol.StackTraceRequest;
import hxcppdbg.core.thread.NativeThread;
import hxcppdbg.dap.protocol.PauseRequest;
import hxcppdbg.dap.protocol.Response;
import hxcppdbg.core.drivers.Interrupt;
import hxcppdbg.dap.protocol.Request;
import hxcppdbg.dap.protocol.ProtocolMessage;
import hxcppdbg.dap.protocol.LaunchRequest;
import hxcppdbg.dap.protocol.Thread;
import hxcppdbg.core.Session;
import hxcppdbg.core.ds.Result;
import haxe.Exception;
import tink.CoreApi.Noise;
import tink.CoreApi.Error;
import tink.CoreApi.Future;
import tink.CoreApi.Promise;
import tink.CoreApi.Outcome;
import haxe.ds.Option;
import cpp.asio.Code;
import cpp.asio.streams.IReadStream;
import cpp.asio.streams.IWriteStream;
import haxe.Json;
import haxe.io.Bytes;

using Lambda;

class DapSession
{
    final input : IReadStream;

    final output : IWriteStream;

    final buffer : InputBuffer;

    var outSequence : Int;

    var session : Option<Session>;

    public function new(_input, _output)
    {
        input       = _input;
        output      = _output;
        buffer      = new InputBuffer();
        outSequence = 1;
        session     = Option.None;

        input.read(onInput);
    }

    function write(_content : String, _callback : Option<Code>->Void)
    {
        final str  = 'Content-Length: ${ _content.length }\r\n\r\n$_content';
        final data = Bytes.ofString(str);
        
        output.write(data, _callback);
    }

    function onInput(_result : cpp.asio.Result<Bytes, Code>)
    {
        switch _result
        {
            case Success(data):
                Future
                    .inSequence(buffer.append(data).map(makeMessage))
                    .handle(onMessagesProcessed);
            case Error(error):
                Sys.println(error.toString());
        }
    }

    function makeMessage(_message : ProtocolMessage) : Future<Noise>
    {
        return
            Promise
                .irreversible((_resolve : Noise->Void, _reject : Error->Void) -> {
                    Sys.println('MSG : ${ _message }');

                    switch _message.type
                    {
                        case 'request':
                            makeRequest(cast _message, _resolve, _reject);
                        case other:
                            _reject(new Error('Unsupported message type "$other"'));
                    }
                })
                .asFuture();
    }

    function makeRequest(_request : Request, _resolve : Noise->Void, _reject : Error->Void)
    {
        function handleResponse(_outcome : tink.core.Outcome<Noise, tink.core.Error>)
        {
            switch _outcome
            {
                case Success(data):
                    _resolve(data);
                case Failure(failure):
                    _reject(failure);
            }
        }

        function sendResponse(_outcome : tink.core.Outcome<Null<Any>, tink.core.Error>)
        {
            return switch _outcome
            {
                case Success(data):
                    respond(_request, Result.Success(data));
                case Failure(failure):
                    respond(_request, Result.Error(failure));
            }
        }

        switch _request.command
        {
            case 'initialize':
                sendResponse(tink.core.Outcome.Success(null))
                    .handle(handleResponse);
            case 'launch':
                onLaunch(cast _request)
                    .flatMap(sendResponse)
                    .flatMap(_outcome -> {
                        return switch _outcome
                        {
                            case Success(data):
                                event({ seq : nextOutSequence(), type : 'event', event : 'initialized' });
                            case Failure(failure):
                                Promise.reject(failure);
                        }
                    })
                    .handle(handleResponse);
            case 'threads':
                onThreads()
                    .flatMap(sendResponse)
                    .handle(handleResponse);
            case 'pause':
                onPause()
                    .flatMap(sendResponse)
                    .flatMap(_outcome -> {
                        return switch _outcome
                        {
                            case Success(data):
                                event({
                                    seq   : nextOutSequence(),
                                    type  : 'event',
                                    event : 'stopped',
                                    body  : {
                                        reason            : 'pause',
                                        description       : 'Paused',
                                        allThreadsStopped : true
                                    }
                                });
                            case Failure(failure):
                                Promise.reject(failure);
                        }
                    })
                    .handle(handleResponse);
            case 'continue':
                onContinue()
                    .flatMap(sendResponse)
                    .handle(handleResponse);
            case 'stackTrace':
                onStackTrace(cast _request)
                    .flatMap(sendResponse)
                    .handle(handleResponse);
            case 'disconnect':
                onDisconnect()
                    .flatMap(sendResponse)
                    .handle(handleResponse);
            case 'setExceptionBreakpoints':
                sendResponse(tink.core.Outcome.Success({ filters : [] }))
                    .handle(handleResponse);
            case other:
                _reject(new Error('Unsupported request command "$other"'));
        }
    }

    function onLaunch(_request : LaunchRequest)
    {
        session = Option.Some(new Session(_request.arguments.program, _request.arguments.sourcemap));

        return
            Promise
                .irreversible((_resolve : Null<Any>->Void, _reject : Error->Void) -> {
                    switch session
                    {
                        case Some(s):
                            s.start(result -> {
                                switch result
                                {
                                    case Success(run):
                                        run(onRunCallback);

                                        _resolve(null);
                                    case Error(exn):
                                        _reject(errorFromException(exn));
                                }
                            });
                        case None:
                            _reject(noSessionError());
                    }
                });
    }

    function onPause()
    {
        return
            Promise
                .irreversible((_resolve : Null<Any>->Void, _reject : Error->Void) -> {
                    switch session
                    {
                        case Some(s):
                            s.pause(result -> {
                                switch result
                                {
                                    case Success(_):
                                        _resolve(null);
                                    case Error(exn):
                                        _reject(errorFromException(exn));
                                }
                            });
                        case None:
                            _reject(noSessionError());
                    }
                });
    }

    function onThreads()
    {
        function toProtocolThread(_thread : NativeThread) : Thread
        {
            return {
                name : _thread.name,
                id   : _thread.index
            }
        }

        return
            Promise
                .irreversible((_resolve : Null<Any>->Void, _reject : Error->Void) -> {
                    switch session
                    {
                        case Some(s):
                            s.pause(result -> {
                                switch result
                                {
                                    case Success(paused):
                                        s.threads.getThreads(result -> {
                                            if (paused)
                                            {
                                                s.resume(result -> {
                                                    switch result
                                                    {
                                                        case Success(run):
                                                            run(onRunCallback);
                                                        case Error(exn):
                                                            _reject(errorFromException(exn));
                                                    }
                                                });
                                            }

                                            switch result
                                            {
                                                case Success(threads):
                                                    _resolve({ threads : threads.map(toProtocolThread) });
                                                case Error(exn):
                                                    _reject(errorFromException(exn));
                                            }
                                        });
                                    case Error(exn):
                                        _reject(errorFromException(exn));
                                }
                            });
                        case None:
                            _reject(noSessionError());
                    }
                });
    }

    function onContinue()
    {
        return
            Promise
                .irreversible((_resolve : Null<Any>->Void, _reject : Error->Void) -> {
                    switch session
                    {
                        case Some(s):
                            s.resume(result -> {
                                switch result
                                {
                                    case Success(run):
                                        run(onRunCallback);

                                        _resolve(null);
                                    case Error(exn):
                                        _reject(errorFromException(exn));
                                }
                            });
                        case None:
                            _reject(noSessionError());
                    }
                });
    }

    function onStackTrace(_request : StackTraceRequest)
    {
        function toProtocolFrame(_idx : Int, _frame : hxcppdbg.core.stack.StackFrame) : StackFrame
        {
            final id = new FrameId(_request.arguments.threadId, _idx);

            return switch _frame
            {
                case Haxe(haxe, native):
                    {
                        id        : id,
                        line      : haxe.expr.haxe.start.line,
                        endLine   : haxe.expr.haxe.end.line,
                        column    : haxe.expr.haxe.start.col,
                        endColumn : haxe.expr.haxe.end.col,
                        name      : switch haxe.closure {
                            case Some(closure):
                                '${ haxe.file.type }.${ haxe.func.name }.${ closure.name }';
                            case None:
                                '${ haxe.file.type }.${ haxe.func.name }';
                        },
                        presentationHint: Normal,
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
                        presentationHint : Subtle,
                        source : {
                            name : native.func,
                            path : native.file
                        }
                    }
            }
        }

        return
            Promise
                .irreversible((_resolve : Null<Any>->Void, _reject : Error->Void) -> {
                    switch session
                    {
                        case Some(s):
                            s.stack.getCallStack(_request.arguments.threadId, result -> {
                                switch result
                                {
                                    case Success(frames):
                                        _resolve({ stackFrames : frames.mapi(toProtocolFrame) });
                                    case Error(exn):
                                        _reject(errorFromException(exn));
                                }
                            });
                        case None:
                            _reject(noSessionError());
                    }
                });
    }

    function onDisconnect()
    {
        return
            Promise
                .irreversible((_resolve : Null<Any>->Void, _reject : Error->Void) -> {
                    switch session
                    {
                        case Some(s):
                            s.stop(result -> {
                                switch result
                                {
                                    case Some(exn):
                                        _reject(errorFromException(exn));
                                    case None:
                                        _resolve(null);
                                }
                            });
                        case None:
                            _reject(noSessionError());
                    }
                });
    }

    function onMessagesProcessed(_result : Array<Noise>)
    {
        Sys.println('${ _result.length } messages processed');
    }

    function onRunCallback(_result : Result<Option<Interrupt>, Exception>)
    {
        switch _result
        {
            case Success(Option.Some(interrupt)):
                //
            case Success(Option.None):
                //
            case Error(exn):
                //
        }
    }

    function respond(_request : Request, _result : cpp.asio.Result<Null<Any>, tink.CoreApi.Error>) : Promise<Noise>
    {
        return
            Promise
                .irreversible((_resolve : Noise->Void, _reject : Error->Void) -> {
                    final obj : Dynamic = {
                        seq         : nextOutSequence(),
                        type        : 'response',
                        request_seq : _request.seq,
                        command     : _request.command
                    };
                    
                    switch _result
                    {
                        case Success(body):
                            obj.success = true;
                            obj.body    = body;
                        case Error(exn):
                            obj.body = {
                                error : {
                                    id       : 0,
                                    format   : exn.message,
                                    showUser : true
                                }
                            }
                    }

                    Sys.println('OUT : ${ obj }');

                    write(Json.stringify(obj), result -> {
                        switch result
                        {
                            case Some(code):
                                _reject(errorFromCode(code));
                            case None:
                                _resolve(null);
                        }
                    });
                });
    }

    function event(_event : Event)
    {
        return
            Promise
                .irreversible((_resolve : Noise->Void, _reject : Error->Void) -> {
                    final str = Json.stringify(_event);

                    Sys.println('OUT : $str');

                    write(str, result -> {
                        switch result
                        {
                            case Some(code):
                                _reject(errorFromCode(code));
                            case None:
                                _resolve(null);
                        }
                    });
                });
    }

    function nextOutSequence()
    {
        return outSequence++;
    }

    static function noSessionError()
    {
        return new Error('Session has not yet started');
    }

    static function errorFromException(_exn : Exception)
    {
        return new Error(_exn.message);
    }

    static function errorFromCode(_code : Code)
    {
        return new Error(_code.toString());
    }
}