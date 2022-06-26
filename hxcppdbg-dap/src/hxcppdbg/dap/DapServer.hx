package hxcppdbg.dap;

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

class DapServer
{
    final events : EventLoop;

    var configured : Bool;

    var buffer : InputBuffer;

    var stdin : TTY;

    var stdout : TTY;

    var log : File;

    public function new(_events : EventLoop)
    {
        events     = _events;
        configured = false;
        buffer     = new InputBuffer();
    }

    public function read()
    {
        cpp.asio.File.open('log.txt', OpenMode.Create | OpenMode.WriteOnly, AccessMode.UserReadWriteExecute, result -> {
            switch result
            {
                case Success(_log):
                    log = _log;
                case Error(error):
                    throw new Exception(error.toString());
            }
        });

        cpp.asio.TTY.open(Stdout, result ->
        {
            switch result
            {
                case Success(_stdout):
                    stdout = _stdout;
                case Error(error):
                    throw new Exception(error.toString());
            }
        });

        cpp.asio.TTY.open(Stdin, result ->
        {
            switch result
            {
                case Success(_stdin):
                    stdin = _stdin;
                    stdin.read.read(onInput);
                case Error(error):
                    throw new Exception(error.toString());
            }
        });
    }

    public function write(_content : String)
    {
        final data = Bytes.ofString('Content-Length: ${ _content.length }\r\n\r\n$_content');

        log.write(data, _ -> {});
        
        stdout.write.write(data, _ -> {});
    }

    function onInput(_result : Result<Bytes, Code>)
    {
        switch _result
        {
            case Success(data):
                log.write(Bytes.ofString('data : ${ data.toString() }'), _ -> {});
                
                switch buffer.append(data)
                {
                    case Some(message):
                        log.write(Bytes.ofString(Json.stringify(message)), _ -> {});

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
                                    case other:
                                        //
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
                log.write(Bytes.ofString('error : $code'), _ -> {});
                stdin.read.stop();
                stdin.close();
                stdout.close();
        }
    }

    function initialise(_sequence : Int)
    {
        write(
            Json.stringify({
                seq     : _sequence,
                type    : 'response',
                success : true,
                command : 'initialize',
                body    : {
                    supportsConfigurationDoneRequest : true,
                    supportsRestartRequest : true,
                    supportTerminateDebuggee : true
                }
            })
        );
    }

    function finishConfiguration(_sequence : Int)
    {
        configured = true;

        write(
            Json.stringify({
                seq     : _sequence,
                type    : 'response',
                success : true,
                command : 'configurationDone',
            })
        );
    }

    function disconnect(_sequence : Int)
    {
        write(
            Json.stringify({
                seq     : _sequence,
                type    : 'response',
                success : true,
                command : 'disconnect',
            })
        );

        stdin.close();
        stdout.close();
    }
}