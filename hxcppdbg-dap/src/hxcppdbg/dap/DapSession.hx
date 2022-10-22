package hxcppdbg.dap;

import cpp.asio.Code;
import cpp.asio.streams.IReadStream;
import cpp.asio.streams.IWriteStream;
import haxe.Json;
import haxe.Exception;
import haxe.io.Bytes;
import haxe.ds.Option;
import tink.CoreApi.Noise;
import tink.CoreApi.Future;
import tink.CoreApi.Outcome;
import tink.CoreApi.Surprise;
import hxcppdbg.dap.FrameId;
import hxcppdbg.dap.protocol.Event;
import hxcppdbg.dap.protocol.Request;
import hxcppdbg.dap.protocol.ProtocolMessage;
import hxcppdbg.dap.protocol.data.Scope;
import hxcppdbg.dap.protocol.data.Thread;
import hxcppdbg.dap.protocol.data.StackFrame;
import hxcppdbg.dap.protocol.data.Breakpoint;
import hxcppdbg.dap.protocol.requests.NextRequest;
import hxcppdbg.dap.protocol.requests.ScopesRequest;
import hxcppdbg.dap.protocol.requests.LaunchRequest;
import hxcppdbg.dap.protocol.requests.EvaluateRequest;
import hxcppdbg.dap.protocol.requests.VariablesRequest;
import hxcppdbg.dap.protocol.requests.StackTraceRequest;
import hxcppdbg.dap.protocol.requests.SetBreakpointsRequest;
import hxcppdbg.dap.protocol.responses.ScopesResponse;
import hxcppdbg.dap.protocol.responses.ThreadsResponse;
import hxcppdbg.dap.protocol.responses.EvaluateResponse;
import hxcppdbg.dap.protocol.responses.VariablesResponse;
import hxcppdbg.dap.protocol.responses.StackTraceResponse;
import hxcppdbg.dap.protocol.responses.SetBreakpointsResponse;
import hxcppdbg.core.Session;
import hxcppdbg.core.StepType;
import hxcppdbg.core.StopReason;
import hxcppdbg.core.ds.Path;
import hxcppdbg.core.ds.Result;
import hxcppdbg.core.model.Model;
import hxcppdbg.core.model.Printer;
import hxcppdbg.core.model.ModelData;
import hxcppdbg.core.thread.NativeThread;

using Lambda;
using StringTools;

typedef DapPromise<T> = Surprise<T, Exception>;

class DapSession
{
    final input : IReadStream;

    final output : IWriteStream;

    final close : Void->Void;

    final buffer : InputBuffer;
    
    final messageQueue : Array<ProtocolMessage>;

    var variables : VariableCache;

    var outSequence : Int;

    var session : Option<Session>;

    var launch : Option<LaunchRequest>;

    public function new(_input, _output, _close)
    {
        input        = _input;
        output       = _output;
        close        = _close;
        buffer       = new InputBuffer();
        messageQueue = [];

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
                final messages = buffer.append(data);
                final length   = messageQueue.length;

                for (message in messages)
                {
                    messageQueue.push(message);
                }

                if (length == 0)
                {
                    consumeMessage();
                }
            case Error(error):
                Sys.println(error.toString());
        }
    }

    function consumeMessage()
    {
        if (messageQueue.length <= 0)
        {
            return;
        }

        makeMessage(messageQueue[0])
            .handle(_ -> {
                messageQueue.shift();

                consumeMessage();
            });
    }

    function makeMessage(_message : ProtocolMessage)
    {
        return switch _message.type
        {
            case 'request':
                makeRequest(cast _message);
            case other:
                DapPromise.sync(Outcome.Failure(new Exception('Unsupported message type "$other"')));
        }
    }

    function makeRequest(_request : Request<Any>)
    {
        function sendResponse(_outcome : Outcome<Any, Exception>)
        {
            return respond(_request, _outcome);
        }

        Sys.println('MSG : ${ _request }');

        return switch _request.command
        {
            case 'initialize':
                sendResponse(Outcome.Success({ supportsConfigurationDoneRequest : true, supportsVariableType : true }))
                    .flatMap(sendInitialisedEvent);
            case 'setExceptionBreakpoints':
                sendResponse(Outcome.Success({ filters : [] }));
            case 'setBreakpoints':
                onSetBreakpoints(cast _request)
                    .flatMap(sendResponse);
            case 'configurationDone':
                sendResponse(Outcome.Success(null))
                    .flatMap(startTargetAfterConfiguration);
            case 'launch':
                onLaunch(cast _request)
                    .flatMap(outcome -> {
                        return switch outcome
                        {
                            case Success(data):
                                DapPromise.sync(Outcome.Success((null : Noise)));
                            case Failure(failure):
                                sendResponse(outcome);
                        }
                    });
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
                onScopes(cast _request)
                    .flatMap(sendResponse);
            case 'variables':
                onVariables(cast _request)
                    .flatMap(sendResponse);
            case 'evaluate':
                onEvaluate(cast _request)
                    .flatMap(sendResponse);
            case 'disconnect':
                onDisconnect()
                    .flatMap(sendResponse)
                    .flatMap(outcome -> {
                        session = Option.None;

                        close();

                        return outcome;
                    });
            case other:
                DapPromise.sync(Outcome.Failure(new Exception('Unsupported request command "$other"')));
        }
    }

    function sendInitialisedEvent(_outcome : Outcome<Noise, Exception>)
    {
        return switch _outcome
        {
            case Success(data):
                event({ seq : nextOutSequence(), type : 'event', event : 'initialized' });
            case Failure(_):
                DapPromise.sync(_outcome);
        }
    }

    function sendPauseStoppedEvent(_outcome : Outcome<Noise, Exception>)
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
            case Failure(exn):
                DapPromise.sync(Outcome.Failure(exn));
        }
    }

    function startTargetAfterConfiguration(_outcome : Outcome<Noise, Exception>)
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
                                DapPromise
                                    .irreversible((_resolve : Outcome<Noise, Exception>->Void) -> {
                                        s.start(result -> {
                                            switch result
                                            {
                                                case Success(run):
                                                    run(onRunCallback);

                                                    _resolve(Outcome.Success(null));
                                                case Error(exn):
                                                    _resolve(Outcome.Failure(exn));
                                            }
                                        });
                                    })
                                    .flatMap(outcome -> {
                                        return switch outcome
                                        {
                                            case Success(_):
                                                respond(req, Outcome.Success(null));
                                            case Failure(exn):
                                                DapPromise.sync(Outcome.Failure(exn));
                                        }
                                    });
                            case None:
                                DapPromise.sync(Outcome.Failure(noSessionException()));
                        }
                    case None:
                        DapPromise.sync(Outcome.Failure(new Exception('no launch request received')));
                }
            case Failure(exn):
                DapPromise.sync(Outcome.Failure(exn));
        }
    }

    // #region requests

    function onLaunch(_request : LaunchRequest)
    {
        return
            DapPromise
                .irreversible((_resolve : Outcome<Noise, Exception>->Void) -> {
                    Session.create(_request.arguments.program, _request.arguments.sourcemap, result -> {
                        switch result {
                            case Success(created):
                                session = Option.Some(created);
                                launch  = Option.Some(_request);

                                _resolve(Outcome.Success(null));
                            case Error(exn):
                                _resolve(Outcome.Failure(exn));
                        }
                    });
                });
    }

    function onPause()
    {
        return
            DapPromise
                .irreversible((_resolve : Outcome<Noise, Exception>->Void) -> {
                    switch session
                    {
                        case Some(s):
                            s.pause(result -> {
                                switch result
                                {
                                    case Success(v):
                                        _resolve(Outcome.Success(null));
                                    case Error(exn):
                                        _resolve(Outcome.Failure(exn));
                                }
                            });
                        case None:
                            _resolve(Outcome.Failure(noSessionException()));
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
            DapPromise
                .irreversible((_resolve : Outcome<ThreadsResponse, Exception>->Void) -> {
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
                                                            // Not sure what to do, should we send a "stopped" event?
                                                            throw exn;
                                                    }
                                                });
                                            }

                                            switch result
                                            {
                                                case Success(threads):
                                                    _resolve(Outcome.Success({ threads : threads.map(toProtocolThread) }));
                                                case Error(exn):
                                                    _resolve(Outcome.Failure(exn));
                                            }
                                        });
                                    case Error(exn):
                                        _resolve(Outcome.Failure(exn));
                                }
                            });
                        case None:
                            _resolve(Outcome.Failure(noSessionException()));
                    }
                });
    }

    function onContinue()
    {
        return
            DapPromise
                .irreversible((_resolve : Outcome<Noise, Exception>->Void) -> {
                    switch session
                    {
                        case Some(s):
                            s.resume(result -> {
                                switch result
                                {
                                    case Success(run):
                                        run(onRunCallback);

                                        _resolve(Outcome.Success(null));
                                    case Error(exn):
                                        _resolve(Outcome.Failure(exn));
                                }
                            });
                        case None:
                            _resolve(Outcome.Failure(noSessionException()));
                    }
                });
    }

    function onStep(_request : NextRequest, _type : StepType)
    {
        return
            DapPromise
                .irreversible((_resolve : Outcome<Noise, Exception>->Void) -> {
                    switch session
                    {
                        case Some(s):
                            s.step(_request.arguments.threadId, _type, result -> {
                                switch result
                                {
                                    case Success(opt):
                                        respond(_request, Outcome.Success(null))
                                            .flatMap(_ -> interruptOptionToEvent(opt, 'step', _request.arguments.threadId))
                                            .handle(_resolve);
                                    case Error(exn):
                                        _resolve(Outcome.Failure(exn));
                                }
                            });
                        case None:
                            _resolve(Outcome.Failure(noSessionException()));
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
                            path : haxe.file.haxe.toString()
                        },
                        sources : [
                            {
                                name : native.func,
                                path : native.file.toString()
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
                            path : native.file.toString()
                        }
                    }
            }
        }

        return
            DapPromise
                .irreversible((_resolve : Outcome<StackTraceResponse, Exception>->Void) -> {
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

                                        _resolve(Outcome.Success({ stackFrames : mapped }));
                                    case Error(exn):
                                        _resolve(Outcome.Failure(exn));
                                }
                            });
                        case None:
                            _resolve(Outcome.Failure(noSessionException()));
                    }
                });
    }

    function onDisconnect()
    {
        return
            DapPromise
                .irreversible((_resolve : Outcome<Noise, Exception>->Void) -> {
                    switch session
                    {
                        case Some(s):
                            s.stop(result -> {
                                switch result
                                {
                                    case Some(exn):
                                        _resolve(Outcome.Failure(exn));
                                    case None:
                                        _resolve(Outcome.Success(null));
                                }
                            });
                        case None:
                            _resolve(Outcome.Failure(noSessionException()));
                    }
                });
    }

    function onSetBreakpoints(_request : SetBreakpointsRequest)
    {
        function removeExistingBreakpointsForSource(_session : Session, _existing : Array<hxcppdbg.core.breakpoints.Breakpoint>)
        {
            final promises =
                _existing
                    .filter(bp -> bp.file.matches(Path.of(_request.arguments.source.path)))
                    .map(bp -> promiseForBreakpointRemoval(_session, bp));

            return @:privateAccess Future.processMany(promises, 1, o -> o, o -> o);
        }

        function createBreakpointsForSource(_session : Session)
        {
            final promises =
                _request.arguments.breakpoints.map(bp -> {
                    return
                        promiseForBreakpointCreation(_session, Path.of(_request.arguments.source.path), bp.line, if (bp.column == null) 0 else bp.column)
                            .flatMap(outcome -> {
                                return switch outcome
                                {
                                    case Success(created):
                                        Outcome.Success(breakpointToProtocolBreakpoint(created));
                                    case Failure(failure):
                                        Outcome.Success(({ verified : false, message : failure.message } : Breakpoint));
                                }
                            });
                    });

            return @:privateAccess Future.processMany(promises, 1, o -> o, o -> o);
        }

        return
            DapPromise
                .irreversible((_resolve : Outcome<SetBreakpointsResponse, Exception>->Void) -> {
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
                                                    case Failure(exn):
                                                        DapPromise.sync(Outcome.Failure(exn));
                                                }
                                            })
                                            .handle(outcome -> {
                                                if (paused)
                                                {
                                                    s.resume(result -> {
                                                        switch result
                                                        {
                                                            case Success(run):
                                                                run(onRunCallback);
                                                            case Error(exn):
                                                                // Not sure what to do, should we send a "stopped" event?
                                                                throw exn;
                                                        }
                                                    });
                                                }
                                                
                                                switch outcome
                                                {
                                                    case Success(created):
                                                        _resolve(Outcome.Success({ breakpoints : created }));
                                                    case Failure(exn):
                                                        _resolve(Outcome.Failure(exn));
                                                }
                                            });
                                    case Error(exn):
                                        _resolve(Outcome.Failure(exn));
                                }
                            });
                        case None:
                            _resolve(Outcome.Failure(noSessionException()));
                    }
                });
    }

    function onScopes(_request : ScopesRequest)
    {
        return
            DapPromise
                .irreversible((_resolve : Outcome<ScopesResponse, Exception>->Void) -> {
                    switch session
                    {
                        case Some(s):
                            final frameId = (cast _request.arguments.frameId : FrameId);

                            final getArguments = Future.irreversible((_resolve : Scope->Void) -> {
                                s.locals.getArguments(frameId.thread, frameId.number, result -> {
                                    switch result
                                    {
                                        case Success(args):
                                            _resolve({ name : 'arguments', variablesReference : variables.insert(args), expensive : false });
                                        case Error(_):
                                            _resolve({ name : 'arguments', variablesReference : 0, expensive : false });
                                    }
                                });
                            });

                            final getLocals = Future.irreversible((_resolve : Scope->Void) -> {
                                s.locals.getLocals(frameId.thread, frameId.number, result -> {
                                    switch result
                                    {
                                        case Success(locals):
                                            _resolve({ name : 'locals', variablesReference : variables.insert(locals), expensive : false });
                                        case Error(_):
                                            _resolve({ name : 'locals', variablesReference : 0, expensive : false });
                                    }
                                });
                            });

                            Future
                                .inSequence([ getArguments, getLocals ])
                                .flatMap(scopes -> Outcome.Success(({ scopes : scopes } : ScopesResponse)))
                                .handle(_resolve);
                        case None:
                            _resolve(Outcome.Failure(noSessionException()));
                    }
                });
    }

    function onVariables(_request : VariablesRequest)
    {
        return
            DapPromise
                .irreversible((_resolve : Outcome<VariablesResponse, Exception>->Void) -> {
                    switch variables.get(_request.arguments.variablesReference)
                    {
                        case Some(vs):
                            _resolve(Outcome.Success({ variables : vs }));
                        case None:
                            _resolve(Outcome.Failure(new Exception('no variables for reference ${ _request.arguments.variablesReference }')));
                    }
                });
    }

    function onEvaluate(_request : EvaluateRequest)
    {
        return
            DapPromise
                .irreversible((_resolve : Outcome<EvaluateResponse, Exception>->Void) -> {
                    switch session
                    {
                        case Some(s):
                            switch _request.arguments.frameId
                            {
                                case null:
                                    _resolve(Outcome.Failure(new Exception('no frame ID')));
                                case frame:
                                    s.eval.evaluate(_request.arguments.expression, frame.thread, frame.number, result -> {
                                        switch result
                                        {
                                            case Success(data):
                                                final reference = switch data
                                                {
                                                    case MEnum(_, _, _), MArray(_), MMap(_), MDynamic(_), MAnon(_), MClass(_, _):
                                                        variables.insert([ LocalVariable.Haxe(new Model(ModelData.MString('children'), data)) ]);
                                                    case _:
                                                        0;
                                                }

                                                final type = switch data {
                                                    case MEnum(type, _, _), MClass(type, _):
                                                        printType(type);
                                                    case _:
                                                        null;
                                                }

                                                _resolve(Outcome.Success({
                                                    result             : printModelData(data),
                                                    variablesReference : reference,
                                                    type               : type
                                                }));
                                            case Error(exn):
                                                _resolve(Outcome.Failure(exn));
                                        }
                                    });
                            }
                        case None:
                            _resolve(Outcome.Failure(noSessionException()));
                    }
                });
    }

    // #endregion

    function onRunCallback(_result : Result<StopReason, Exception>)
    {
        switch _result
        {
            case Success(reason):
                interruptOptionToEvent(reason, 'pause', null)
                    .handle(_ -> {});
            case Error(exn):
                // Not sure what to do, should we send a "stopped" event?
                throw exn;
        }
    }

    function respond(_request : Request<Any>, _result : Outcome<Any, Exception>)
    {
        return
            DapPromise
                .irreversible(_resolve -> {
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
                        case Failure(error):
                            obj.body = {
                                error : {
                                    id       : 0,
                                    format   : error.message,
                                    showUser : true
                                }
                            }
                    }

                    write(Json.stringify(obj), result -> {
                        switch result
                        {
                            case Some(code):
                                _resolve(Outcome.Failure(exceptionFromCode(code)));
                            case None:
                                _resolve(Outcome.Success((null : Noise)));
                        }
                    });
                });
    }

    function event(_event : Event<Any>)
    {
        return
            DapPromise
                .irreversible(_resolve -> {
                    final str = Json.stringify(_event);

                    write(str, result -> {
                        switch result
                        {
                            case Some(code):
                                _resolve(Outcome.Failure(exceptionFromCode(code)));
                            case None:
                                _resolve(Outcome.Success((null : Noise)));
                        }
                    });
                });
    }

    function interruptOptionToEvent(_interrupt : StopReason, _reason : String, _threadId : Null<Int>)
    {
        variables = new VariableCache();

        return switch _interrupt
        {
            case Paused:
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
            case BreakpointHit(_threadIndex, _breakpoint):
                event({
                    seq   : nextOutSequence(),
                    type  : 'event',
                    event : 'stopped',
                    body  : {
                        reason            : 'breakpoint',
                        description       : 'Paused on breakpoint',
                        allThreadsStopped : true,
                        threadId          : _threadIndex,
                        hitBreakpointsIds : [ _breakpoint.id ],
                        preserveFocusHint : false
                    }
                });
            case ExceptionThrown(_threadIndex, _):
                event({
                    seq   : nextOutSequence(),
                    type  : 'event',
                    event : 'stopped',
                    body  : {
                        reason            : 'exception',
                        description       : 'Paused on exception',
                        allThreadsStopped : true,
                        threadId          : _threadIndex,
                        preserveFocusHint : false
                    }
                });
            case Exited(_code):
                event({
                    seq   : nextOutSequence(),
                    type  : 'event',
                    event : 'exited',
                    body  : {
                        exitCode : _code
                    }
                });
        }
    }

    function nextOutSequence()
    {
        return outSequence++;
    }

    static function idOrNull(_option : Option<Int>)
    {
        return switch _option
        {
            case Some(v):
                v;
            case None:
                null;
        }
    }

    static function breakpointToProtocolBreakpoint(_breakpoint : hxcppdbg.core.breakpoints.Breakpoint) : Breakpoint
    {
        return {
            id        : _breakpoint.id,
            verified  : true,
            // line      : _breakpoint.expr.haxe.start.line,
            // column    : _breakpoint.expr.haxe.start.col,
            // endLine   : _breakpoint.expr.haxe.end.line,
            // endColumn : _breakpoint.expr.haxe.end.col
        }
    }

    static function promiseForBreakpointRemoval(_session : Session, _bp : hxcppdbg.core.breakpoints.Breakpoint)
    {
        return
            DapPromise
                .irreversible((_resolve) -> {
                    _session.breakpoints.delete(_bp.id, result -> {
                        switch result
                        {
                            case Some(exn):
                                _resolve(Outcome.Failure(exn));
                            case None:
                                _resolve(Outcome.Success((null : Noise)));
                        }
                    });
                });
    }

    static function promiseForBreakpointCreation(_session : Session, _file : Path, _line : Int, _char : Int)
    {
        return
            DapPromise
                .irreversible(_resolve -> {
                    _session.breakpoints.create(_file, _line, _char, result -> {
                        switch result
                        {
                            case Success(bp):
                                _resolve(Outcome.Success(bp));
                            case Error(exn):
                                _resolve(Outcome.Failure(exn));
                        }
                    });
                });
    }

    static function noSessionException()
    {
        return new Exception('Session has not yet started');
    }

    static function exceptionFromCode(_code : Code)
    {
        return new Exception(_code.toString());
    }
}