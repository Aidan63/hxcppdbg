package hxcppdbg.dap;

import sys.thread.EventLoop.EventHandler;
import sys.thread.Thread;
import haxe.io.Error;
import sys.net.Host;
import sys.net.Socket;
import haxe.io.Bytes;
import haxe.io.Output;
import haxe.io.Eof;
import haxe.io.Input;
import haxe.Json;

class DapServer
{
    var server : Null<Socket>;

    var configured : Bool;

    var handler : EventHandler;

    public function new()
    {
        server     = null;
        configured = false;
        handler    = null;
    }

    public function read()
    {
        try
        {
            final header = server.input.readLine();
            final split  = header.split(':');

            trace(header);
    
            switch Std.parseInt(split[1])
            {
                case null:
                    trace('failed to parse length from "${ header }"');
                case length:
                    trace(length);

                    // "+ 2" as we need to read past the second "\r\n" indicating a split between the header and content.
                    final content = server.input.readString(length + 2);

                    trace(content);

                    final message = Json.parse(content);
    
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
        }
        catch (_ : Error)
        {
            //
        }
        catch (_ : Eof)
        {
            //
        }
    }

    public function listen()
    {
        final socket = new Socket();
        socket.bind(new Host('127.0.0.1'), 7777);
        socket.listen(1);
        
        server = socket.accept();
        server.setBlocking(false);

        handler = Thread.current().events.repeat(read, 0);
    }

    public function write(_content : String)
    {
        final data = 'Content-Length: ${ _content.length }\r\n\r\n$_content';

        trace(data);

        server.output.writeString(data);
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

        Thread.current().events.run(server.close);
        Thread.current().events.cancel(handler);
    }
}