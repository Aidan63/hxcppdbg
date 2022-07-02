package hxcppdbg.dap;

import cpp.asio.streams.IWriteStream;
import cpp.asio.streams.IReadStream;
import sys.thread.EventLoop;
import cpp.asio.File;
import cpp.asio.Result;
import cpp.asio.Code;
import cpp.asio.TTY;
import cpp.asio.OpenMode;
import cpp.asio.AccessMode;
import haxe.Exception;
import haxe.io.Bytes;
import haxe.Json;

class DapSession
{
    final input : IReadStream;

    final output : IWriteStream;

    final buffer : InputBuffer;

    var configured : Bool;

    var outSequence : Int;

    // signals

    public final onDisconnect : Signal<Unit>;

    public final onLaunch : Signal<Unit>;

    public function new(_events, _input, _output)
    {
        input       = _input;
        output      = _output;
        buffer      = new InputBuffer();
        configured  = false;
        outSequence = 1;

        onDisconnect = new Signal(_events);
        onLaunch     = new Signal(_events);

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
                    //
            }
        });
        
        trace(str);
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
                trace('${ data.length } bytes read');

                switch buffer.append(data)
                {
                    case Some(message):
                        trace(message);

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
                        //
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

        onDisconnect.notify(Unit.value);
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

        onLaunch.notify(Unit.value);
    }

    function nextOutSequence()
    {
        return outSequence++;
    }
}