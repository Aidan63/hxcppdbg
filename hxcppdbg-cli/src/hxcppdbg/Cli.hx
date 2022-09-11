package hxcppdbg;

import cpp.asio.streams.IReadStream;
import cpp.asio.TTY;
import tink.CoreApi.Noise;
import tink.CoreApi.Error;
import tink.CoreApi.Promise;
import haxe.io.Bytes;
import haxe.Exception;
import sys.thread.Thread;
import hxcppdbg.core.stack.StackFrame;
import haxe.io.Eof;
import sys.io.File;
import hxcppdbg.core.breakpoints.BreakpointHit;
import sys.FileSystem;
import hxcppdbg.cli.Hxcppdbg;
import hxcppdbg.core.Session;

using Lambda;
using haxe.EnumTools;

class Cli
{
    final regex : EReg;

    public var target : String;

    public var sourcemap : String;

    public function new()
    {
        regex = ~/\s+/g;
    }

    @:defaultCommand public function run()
    {
        return Promise.irreversible((_ : Noise->Void, _reject : Error->Void) -> {
            cpp.asio.Signal.open(result -> {
                switch result
                {
                    case Success(signal):
                        Thread.current().events.repeat(() -> {}, 1000);

                        Session.create(
                            FileSystem.absolutePath(target),
                            FileSystem.absolutePath(sourcemap), 
                            result -> {
                                switch result
                                {
                                    case Success(session):
                                        signal.start(Interrupt, result -> {
                                            switch result
                                            {
                                                case Success(data):
                                                    new Hxcppdbg(session).pause();
                                                case Error(error):
                                                    _reject(new Error(error.toString()));
                                            }
                                        });
                
                                        cpp.asio.TTY.open(Stdin, result -> {
                                            switch result
                                            {
                                                case Success(stdin):
                                                    waitForInput(stdin.read, session, _reject);
                                                case Error(error):
                                                    _reject(new Error(error.toString()));
                                            }
                                        });
                                    case Error(exn):
                                        _reject(new Error(exn.message));
                                }
                            });
                    case Error(error):
                        _reject(new Error(error.toString()));
                }
            });
        });
    }

    @:command public function help()
    {
        //
    }

    function waitForInput(_stdin : IReadStream, _session : Session, _reject : Error->Void)
    {
        Sys.print('hxcppdbg : ');

        _stdin.read(result -> {
            switch result
            {
                case Success(data):
                    _stdin.stop();

                    final str  = data.toString();
                    final args = regex.split(str);

                    tink.Cli
                        .process(args, new Hxcppdbg(_session))
                        .handle(result -> {
                            switch result
                            {
                                case Success(_):
                                    //
                                case Failure(failure):
                                    Sys.println(failure.message);
                            }

                            waitForInput(_stdin, _session, _reject);
                        });
                case Error(error):
                    _reject(new Error(error.toString()));
            }
        });
    }
}