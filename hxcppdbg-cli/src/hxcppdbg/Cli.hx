package hxcppdbg;

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

    var session : Session;

    public var target : String;

    public var sourcemap : String;

    public function new()
    {
        regex = ~/\s+/g;
    }

    @:defaultCommand public function run()
    {
        session = new Session(FileSystem.absolutePath(target), FileSystem.absolutePath(sourcemap));

        cpp.asio.Signal.open(result -> {
            switch result
            {
                case Success(signal):
                    signal.start(Interrupt, result -> {
                        switch result
                        {
                            case Success(data):
                                new Hxcppdbg(session).pause();
                            case Error(error):
                                throw new Exception(error.toString());
                        }
                    });
                case Error(error):
                    throw new Exception(error.toString());
            }
        });

        cpp.asio.TTY.open(Stdout, result -> {
            switch result
            {
                case Success(stdout):
                    cpp.asio.TTY.open(Stdin, result -> {
                        switch result
                        {
                            case Success(stdin):
                                stdout.write.write(Bytes.ofString('hxcppdbg : '), _ -> {});

                                stdin.read.read(result -> {
                                    switch result
                                    {
                                        case Success(data):
                                            final str  = data.toString();
                                            final args = regex.split(str);

                                            tink.Cli
                                                .process(args, new Hxcppdbg(session))
                                                .handle(result -> {
                                                    switch result
                                                    {
                                                        case Success(_):
                                                            //
                                                        case Failure(failure):
                                                            stdout.write.write(Bytes.ofString('${ failure.message }\n'), _ -> {});        
                                                    }

                                                    stdout.write.write(Bytes.ofString('hxcppdbg : '), _ -> {});
                                                });
                                        case Error(error):
                                            throw new Exception(error.toString());
                                    }
                                });
                            case Error(error):
                                throw new Exception(error.toString());
                        }
                    });
                case Error(error):
                    throw new Exception(error.toString());
            }
        });
    }

    @:command public function help()
    {
        //
    }
}