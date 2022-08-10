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

    public final onLaunch : Signal<{ sequence : Int, program : String, sourcemap : String }>;

    public final onPause : Signal<Int>;

    public final onContinue : Signal<Int>;

    public final onStackTrace : Signal<Dynamic>;

    public final onThreads : Signal<Int>;

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
        onContinue   = new Signal();
        onStackTrace = new Signal();
        onThreads    = new Signal();

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
            case Success(body):
                obj.success = true;
                obj.body    = body;
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
                for (message in buffer.append(data))
                {
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
                                    onLaunch.notify({
                                        sequence  : message.seq,
                                        program   : message.arguments.program,
                                        sourcemap : message.arguments.sourcemap
                                    });
                                case 'pause':
                                    onPause.notify(message.seq);
                                case 'continue':
                                    onContinue.notify(message.seq);
                                case 'stackTrace':
                                    onStackTrace.notify(message);
                                case 'threads':
                                    onThreads.notify(message.seq);
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
                }
            case Error(code):
                trace(code);
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
                    supportsConfigurationDoneRequest : true
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