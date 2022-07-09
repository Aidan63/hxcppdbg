package hxcppdbg.dap;

import cpp.asio.Code;
import cpp.asio.Result;
import cpp.asio.streams.IReadStream;
import cpp.asio.streams.IWriteStream;
import hxrx.IObservable;
import hxrx.subjects.PublishSubject;
import haxe.Json;
import haxe.io.Bytes;

class DapSession
{
    final input : IReadStream;

    final output : IWriteStream;

    final buffer : InputBuffer;

    var configured : Bool;

    var outSequence : Int;

    // Observables

    final subjectDisconnect : PublishSubject<Unit>;

    final subjectLaunch : PublishSubject<Unit>;

    final subjectPause : PublishSubject<Unit>;

    public var onDisconnect (get, never) : IObservable<Unit>;

    inline function get_onDisconnect() return subjectDisconnect;

    public var onLaunch (get, never) : IObservable<Unit>;

    inline function get_onLaunch() return subjectLaunch;

    public var onPause (get, never) : IObservable<Unit>;

    inline function get_onPause() return subjectPause;

    public function new(_input, _output)
    {
        input       = _input;
        output      = _output;
        buffer      = new InputBuffer();
        configured  = false;
        outSequence = 1;

        subjectDisconnect = new PublishSubject();
        subjectLaunch     = new PublishSubject();
        subjectPause      = new PublishSubject();

        input.read(onInput);
    }

    function write(_content : String)
    {
        final str  = 'Content-Length: ${ _content.length }\r\n\r\n$_content';
        final data = Bytes.ofString(str);
        
        output.write(data, option -> {
            switch option
            {
                case Some(code):
                    trace('failed to write to output stream : $code');
                case None:
                    Sys.println('SENT : "$str"');
            }
        });
    }

    public function sendBreakpointHit(_breakpointID : Int, _threadID : Int)
    {
        write(
            Json.stringify({
                seq   : nextOutSequence(),
                type  : 'event',
                event : 'stopped',
                body  : {
                    reason            : 'breakpoint',
                    description       : 'Paused on breakpoint',
                    threadId          : _threadID,
                    allThreadsStopped : true,
                    hitBreakpointIds  : [ _breakpointID ]
                }
            })
        );
    }

    public function sendExceptionThrown(_threadID : Int)
    {
        write(
            Json.stringify({
                seq   : nextOutSequence(),
                type  : 'event',
                event : 'stopped',
                body  : {
                    reason            : 'exception',
                    description       : 'Paused on exception',
                    threadId          : _threadID,
                    allThreadsStopped : true,
                }
            })
        );
    }

    public function sendPaused()
    {
        write(
            Json.stringify({
                seq   : nextOutSequence(),
                type  : 'event',
                event : 'stopped',
                body  : {
                    reason            : 'pause',
                    description       : 'Paused',
                    allThreadsStopped : true,
                }
            })
        );
    }

    public function sendExited()
    {
        write(
            Json.stringify({
                seq   : nextOutSequence(),
                type  : 'event',
                event : 'exited',
                body  : {
                    exitCode : 0
                }
            })
        );
    }

    public function sendDisconnect(_sequence)
    {
        write(
            Json.stringify({
                seq         : nextOutSequence(),
                request_seq : _sequence,
                type        : 'response',
                success     : true,
                command     : 'disconnect',
            })
        );
    }

    function onInput(_result : Result<Bytes, Code>)
    {
        switch _result
        {
            case Success(data):
                switch buffer.append(data)
                {
                    case Some(message):
                        Sys.println('RECV : "${ message.toString() }"');

                        switch message.type
                        {
                            case 'request':
                                switch message.command
                                {
                                    case 'initialize':
                                        initialise(message.seq);
                                    case 'configurationDone':
                                        finishConfiguration(message.seq);
                                    case 'disconnect':
                                        disconnect(message.seq);
                                    case 'launch':
                                        launch(message.seq);
                                    case 'pause':
                                        pause(message.seq);
                                    case other:
                                        trace(other);
                                }
                            case 'response':
                                //
                            case 'event':
                                //
                            case _:
                                //
                        }
                    case None:
                        trace(buffer);
                }
            case Error(code):
                //
        }
    }

    function initialise(_sequence : Int)
    {
        write(
            Json.stringify({
                seq         : nextOutSequence(),
                request_seq : _sequence,
                type        : 'response',
                success     : true,
                command     : 'initialize',
                body        : {
                    supportsConfigurationDoneRequest : true,
                    supportsRestartRequest : true,
                    supportTerminateDebuggee : true
                }
            })
        );

        write(
            Json.stringify({
                seq   : nextOutSequence(),
                type  : 'event',
                event : 'initialized'
            })
        );
    }

    function finishConfiguration(_sequence : Int)
    {
        configured = true;

        write(
            Json.stringify({
                seq         : nextOutSequence(),
                request_seq : _sequence,
                type        : 'response',
                success     : true,
                command     : 'configurationDone',
            })
        );
    }

    function disconnect(_sequence : Int)
    {
        write(
            Json.stringify({
                seq         : nextOutSequence(),
                request_seq : _sequence,
                type        : 'response',
                success     : true,
                command     : 'disconnect',
            })
        );

        subjectDisconnect.onNext(Unit.value);
    }

    function launch(_sequence : Int)
    {
        write(
            Json.stringify({
                seq         : nextOutSequence(),
                request_seq : _sequence,
                type        : 'response',
                success     : true,
                command     : 'launch',
            })
        );

        subjectLaunch.onNext(Unit.value);
    }

    function pause(_sequence : Int)
    {
        write(
            Json.stringify({
                seq         : nextOutSequence(),
                request_seq : _sequence,
                type        : 'response',
                success     : true,
                command     : 'pause',
            })
        );

        subjectPause.onNext(Unit.value);
    }

    function nextOutSequence()
    {
        return outSequence++;
    }
}