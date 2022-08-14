package hxcppdbg.dap;

import hxcppdbg.dap.protocol.Breakpoint;
import hxcppdbg.dap.protocol.SetBreakpointsRequest;
import hxcppdbg.core.StepType;
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
import hxcppdbg.dap.protocol.NextRequest;
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
using StringTools;

class DapSession
{
    final input : IReadStream;

    final output : IWriteStream;

    final close : Void->Void;

    final buffer : InputBuffer;

    var outSequence : Int;

    var session : Option<Session>;

    var launch : Option<LaunchRequest>;

    public function new(_input, _output, _close)
    {
        input              = _input;
        output             = _output;
        close              = _close;
        buffer             = new InputBuffer();

        outSequence = 1;
        session     = Option.None;
        launch      = Option.None;

        input.read(onInput);
    }

    function write(_content : String, _callback : Option<Code>->Void)
    {
        Sys.println('OUT : $_content');

        final str  = 'Content-Length: ${ _content.length }\r\n\r\n$_content';
        final data = Bytes.ofString(str);
        
        output.write(data, _callback);
    }

    function onInput(_result : cpp.asio.Result<Bytes, Code>)
    {
        switch _result
        {
            case Success(data):
                Sys.println('RAW : ${ data.toString() }');

                Future
                    .inSequence(buffer.append(data).map(makeMessage))
                    .handle(onMessagesProcessed);
            case Error(error):
                Sys.println(error.toString());
        }
    }

    function makeMessage(_message : ProtocolMessage)
    {
        return switch _message.type
        {
            case 'request':
                makeRequest(cast _message);
            case other:
                Promise.reject(new Error('Unsupported message type "$other"'));
        }
    }

    function makeRequest(_request : Request)
    {
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

        function sendInitialisedEvent(_outcome : tink.core.Outcome<Noise, tink.core.Error>)
        {
            return switch _outcome
            {
                case Success(data):
                    event({ seq : nextOutSequence(), type : 'event', event : 'initialized' });
                case Failure(failure):
                    Promise.reject(failure);
            }
        }

        function sendPauseStoppedEvent(_outcome : tink.core.Outcome<Noise, tink.core.Error>)
        {
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
                            allThreadsStopped : true,
                            preserveFocusHint : false
                        }
                    });
                case Failure(failure):
                    Promise.reject(failure);
            }
        }

        function startTargetAfterConfiguration(_outcome : tink.core.Outcome<Noise, tink.core.Error>)
        {
            return switch _outcome
            {
                case Success(_):
                    switch launch
                    {
                        case Some(req):
                            switch session
                            {
                                case Some(s):
                                    Promise
                                        .irreversible((_resolve : Noise->Void, _reject : Error->Void) -> {
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
                                        })
                                        .flatMap(outcome -> {
                                            return switch outcome
                                            {
                                                case Success(_):
                                                    respond(req, Result.Success(null));
                                                case Failure(failure):
                                                    Promise.reject(failure);
                                            }
                                        });
                                case None:
                                    Promise.reject(noSessionError());
                            }
                        case None:
                            Promise.reject(new Error('no launch request received'));
                    }
                case Failure(failure):
                    Promise.reject(failure);
            }
        }

        Sys.println('MSG : ${ _request }');

        return switch _request.command
        {
            case 'initialize':
                sendResponse(tink.core.Outcome.Success({ supportsConfigurationDoneRequest : true }))
                    .flatMap(sendInitialisedEvent);
            case 'setExceptionBreakpoints':
                sendResponse(tink.core.Outcome.Success({ filters : [] }));
            case 'setBreakpoints':
                onSetBreakpoints(cast _request)
                    .flatMap(sendResponse);
            case 'configurationDone':
                sendResponse(tink.core.Outcome.Success(null))
                    .flatMap(startTargetAfterConfiguration);
            case 'launch':
                onLaunch(cast _request);
            case 'threads':
                onThreads()
                    .flatMap(sendResponse);
            case 'pause':
                onPause()
                    .flatMap(sendResponse)
                    .flatMap(sendPauseStoppedEvent);
            case 'continue':
                onContinue()
                    .flatMap(sendResponse);
            case 'next':
                onStep(cast _request, StepType.Over);
            case 'stepIn':
                onStep(cast _request, StepType.In);
            case 'stepOut':
                onStep(cast _request, StepType.Out);
            case 'stackTrace':
                onStackTrace(cast _request)
                    .flatMap(sendResponse);
            case 'scopes':
                sendResponse(tink.core.Outcome.Success({ scopes : [] }));
            case 'disconnect':
                onDisconnect()
                    .flatMap(sendResponse)
                    .next(noise -> {
                        session = Option.None;

                        close();

                        return noise;
                    });
            case other:
                Promise.reject(new Error('Unsupported request command "$other"'));
        }
    }

    // #region requests

    function onLaunch(_request : LaunchRequest)
    {
        session = Option.Some(new Session(_request.arguments.program, _request.arguments.sourcemap));
        launch  = Option.Some(_request);

        return Promise.resolve(null);
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

    function onStep(_request : NextRequest, _type : StepType)
    {
        return
            Promise
                .irreversible((_resolve : Noise->Void, _reject : Error->Void) -> {
                    switch session
                    {
                        case Some(s):
                            s.step(_request.arguments.threadId, _type, result -> {
                                switch result
                                {
                                    case Success(opt):
                                        respond(_request, cpp.asio.Result.Success(null))
                                            .flatMap(_ -> interruptOptionToEvent(opt, 'step', _request.arguments.threadId))
                                            .handle(outcome -> {
                                                switch outcome
                                                {
                                                    case Success(data):
                                                        _resolve(data);
                                                    case Failure(failure):
                                                        _reject(failure);
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
                                        final mapped = [];

                                        for (idx => frame in frames)
                                        {
                                            switch frame
                                            {
                                                case Haxe(_, _):
                                                    mapped.push(toProtocolFrame(idx, frame));
                                                case Native(_):
                                                    //
                                            }
                                        }

                                        _resolve({ stackFrames : mapped });
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

    function onSetBreakpoints(_request : SetBreakpointsRequest)
    {
        function removeExistingBreakpointsForSource(_session : Session, _existing : Array<hxcppdbg.core.breakpoints.Breakpoint>)
        {
            return
                Promise
                    .inSequence(
                        _existing
                            .filter(bp -> bp.file.endsWith(_request.arguments.source.name))
                            .map(bp -> promiseForBreakpointRemoval(_session, bp)))
                    .next(_ -> (null : Noise));
        }

        function createBreakpointsForSource(_session : Session)
        {
            return
                Promise
                    .inSequence(
                        _request.arguments.breakpoints.map(bp -> {
                            return
                                promiseForBreakpointCreation(_session, _request.arguments.source.name, bp.line, if (bp.column == null) 0 else bp.column)
                                    .flatMap(outcome -> {
                                        return Promise.resolve(switch outcome
                                        {
                                            case Success(created):
                                                breakpointToProtocolBreakpoint(created);
                                            case Failure(failure):
                                                ({ verified : false, message : failure.message } : Breakpoint);
                                        });
                                    });
                            })
                        );
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
                                        removeExistingBreakpointsForSource(s, s.breakpoints.list())
                                            .flatMap(outcome -> {
                                                return switch outcome
                                                {
                                                    case Success(data):
                                                        createBreakpointsForSource(s);
                                                    case Failure(failure):
                                                        Promise.reject(failure);
                                                }
                                            })
                                            .handle(outcome -> {
                                                switch outcome
                                                {
                                                    case Success(created):
                                                        _resolve({ breakpoints : created });
                                                    case Failure(failure):
                                                        _reject(failure);
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

    // #endregion

    function onMessagesProcessed(_result : Array<Outcome<Noise, Error>>)
    {
        Sys.println('${ _result.length } messages processed');
    }

    function onRunCallback(_result : Result<Option<Interrupt>, Exception>)
    {
        switch _result
        {
            case Success(opt):
                interruptOptionToEvent(opt, 'pause', null)
                    .handle(handleRunEventPromise);
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

    function interruptOptionToEvent(_interrupt : Option<Interrupt>, _reason : String, _threadId : Null<Int>)
    {
        return
            switch _interrupt
            {
                case Option.None:
                    event({
                        seq   : nextOutSequence(),
                        type  : 'event',
                        event : 'stopped',
                        body  : {
                            reason            : _reason,
                            description       : 'Paused',
                            threadId          : _threadId,
                            allThreadsStopped : true,
                            preserveFocusHint : false
                        }
                    });
                case Option.Some(Interrupt.ExceptionThrown(threadIndex)):
                    event({
                        seq   : nextOutSequence(),
                        type  : 'event',
                        event : 'stopped',
                        body  : {
                            reason            : 'exception',
                            description       : 'Paused on exception',
                            allThreadsStopped : true,
                            threadId          : threadIndex,
                            preserveFocusHint : false
                        }
                    });
                case Option.Some(Interrupt.BreakpointHit(threadIndex, id)):
                    event({
                        seq   : nextOutSequence(),
                        type  : 'event',
                        event : 'stopped',
                        body  : {
                            reason            : 'breakpoint',
                            description       : 'Paused on exception',
                            allThreadsStopped : true,
                            threadId          : threadIndex,
                            hitBreakpointsIds : [ id ],
                            preserveFocusHint : false
                        }
                    });
                case Option.Some(Interrupt.Other):
                    Promise.resolve(null);
            }
    }

    function nextOutSequence()
    {
        return outSequence++;
    }

    static function breakpointToProtocolBreakpoint(_breakpoint : hxcppdbg.core.breakpoints.Breakpoint) : Breakpoint
    {
        return {
            id        : _breakpoint.id,
            verified  : true,
            line      : _breakpoint.expr.haxe.start.line,
            column    : _breakpoint.expr.haxe.start.col,
            endLine   : _breakpoint.expr.haxe.end.line,
            endColumn : _breakpoint.expr.haxe.end.col
        }
    }

    static function promiseForBreakpointRemoval(_session : Session, _bp : hxcppdbg.core.breakpoints.Breakpoint)
    {
        return
            Promise
                .irreversible((_resolve : Noise->Void, _reject : Error->Void) -> {
                    _session.breakpoints.delete(_bp.id, result -> {
                        switch result
                        {
                            case Some(exn):
                                _reject(errorFromException(exn));
                            case None:
                                _resolve(null);
                        }
                    });
                });
    }

    static function promiseForBreakpointCreation(_session : Session, _file : String, _line : Int, _char : Int)
    {
        return
            Promise
                .irreversible((_resolve : hxcppdbg.core.breakpoints.Breakpoint->Void, _reject : Error->Void) -> {
                    _session.breakpoints.create(_file, _line, _char, result -> {
                        switch result
                        {
                            case Success(bp):
                                _resolve(bp);
                            case Error(exn):
                                _reject(errorFromException(exn));
                        }
                    });
                });
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

    static function handleRunEventPromise(_outcome : tink.core.Outcome<Noise, tink.core.Error>)
    {
        //
    }
}