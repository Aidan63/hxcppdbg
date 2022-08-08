package hxcppdbg.dap;

import haxe.ds.Option;
import cpp.asio.Code;
import cpp.asio.Result;
import cpp.asio.streams.IReadStream;
import cpp.asio.streams.IWriteStream;
import haxe.Json;
import haxe.io.Bytes;
import hxcppdbg.core.ds.Signal;

class DapSession
{
    final input : IReadStream;

    final output : IWriteStream;

    final buffer : InputBuffer;

    var configured : Bool;

    var outSequence : Int;

    public final onDisconnect : Signal<Int>;

    public final onLaunch : Signal<Int>;

    public final onPause : Signal<Int>;

    public function new(_input, _output)
    {
        input       = _input;
        output      = _output;
        buffer      = new InputBuffer();
        configured  = false;
        outSequence = 1;

        onDisconnect = new Signal();
        onLaunch     = new Signal();
        onPause      = new Signal();

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

    public function sendBreakpointHit(_breakpointID : Option<Int>, _threadID : Option<Int>)
    {
        write(
            Json.stringify({
                seq   : nextOutSequence(),
                type  : 'event',
                event : 'stopped',
                body  : {
                    reason            : 'breakpoint',
                    description       : 'Paused on breakpoint',
                    threadId          : switch _threadID {
                        case Some(v): v;
                        case None: null;
                    },
                    allThreadsStopped : true,
                    hitBreakpointIds  : switch _breakpointID {
                        case Some(v):
                            [ v ];
                        case None:
                            null;
                    }
                }
            })
        );
    }

    public function sendExceptionThrown(_threadID : Option<Int>)
    {
        write(
            Json.stringify({
                seq   : nextOutSequence(),
                type  : 'event',
                event : 'stopped',
                body  : {
                    reason            : 'exception',
                    description       : 'Paused on exception',
                    threadId          : switch _threadID {
                        case Some(v): v;
                        case None: null;
                    },
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

    public function sendResponse(_sequence : Int, _command : String, _success : DapResponse)
    {
        final obj : Dynamic = {
            seq         : nextOutSequence(),
            request_seq : _sequence,
            type        : 'response',
            command     : _command,
        };
        
        switch _success
        {
            case Success:
                obj.success = true;
            case Failure(exn):
                obj.success = false;
                obj.body = {
                    error : {
                        id       : 0,
                        format   : exn.message,
                        showUser : true
                    }
                }
        }

        write(Json.stringify(obj));
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
                                        onDisconnect.notify(message.seq);
                                    case 'launch':
                                        onLaunch.notify(message.seq);
                                    case 'pause':
                                        onPause.notify(message.seq);
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

    function nextOutSequence()
    {
        return outSequence++;
    }
}