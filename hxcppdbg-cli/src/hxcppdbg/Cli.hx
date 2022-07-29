package hxcppdbg;

import haxe.io.Bytes;
import haxe.Exception;
import sys.thread.Thread;
import hxcppdbg.core.stack.StackFrame;
import haxe.io.Eof;
import sys.io.File;
import hxcppdbg.core.breakpoints.BreakpointHit;
import sys.FileSystem;
import tink.cli.Prompt.PromptType;
import tink.cli.prompt.SysPrompt;
import hxcppdbg.cli.Hxcppdbg;
import hxcppdbg.core.Session;

using Lambda;
using haxe.EnumTools;

class Cli
{
    final input : SysPrompt;

    final regex : EReg;

    var session : Session;

    public var target : String;

    public var sourcemap : String;

    public function new()
    {
        input = new SysPrompt();
        regex = ~/\s+/g;
    }

    @:defaultCommand public function run()
    {
        session = new Session(FileSystem.absolutePath(target), FileSystem.absolutePath(sourcemap));

        session
            .breakpoints
            .onBreakpointHit
            .subscribe(printBreakpointHitLocation);

        session
            .breakpoints
            .onExceptionThrown
            .subscribe(printExceptionLocation);

        Thread.createWithEventLoop(() -> {
            cpp.asio.Signal.open(result -> {
                switch result
                {
                    case Success(signal):
                        signal.start(Interrupt, result -> {
                            switch result
                            {
                                case Success(data):
                                    session.pause(opt -> {
                                        switch opt
                                        {
                                            case Some(v):
                                                trace(v);
                                            case None:
                                                trace('paused');
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
                                                .handle(_ -> stdout.write.write(Bytes.ofString('hxcppdbg : '), _ -> {}));
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

    function printBreakpointHitLocation(_event : BreakpointHit)
    {
        Sys.println('Thread ${ _event.thread } hit breakpoint ${ _event.breakpoint.id } at ${ _event.breakpoint.file } Line ${ _event.breakpoint.line }');

        final minLine = Std.int(Math.max(1, _event.breakpoint.line - 3)) - 1;
        final maxLine = _event.breakpoint.line + 3;
        final input   = File.read(_event.breakpoint.file, false);

        // Read all lines up until the ones we're actually interested in.
        var i = 0;
        while (i < minLine)
        {
            input.readLine();
            i++;
        }

        for (i in 0...(maxLine - minLine))
        {
            try
            {
                final line    = input.readLine();
                final absLine = minLine + i + 1;

                if (_event.breakpoint.line == absLine)
                {
                    Sys.print('=>\t');
                }
                else
                {
                    Sys.print('\t');
                }

                Sys.println('$absLine: $line');
            }
            catch (_ : Eof)
            {
                break;
            }
        }

        input.close();
    }

    function printExceptionLocation(_thread : Int)
    {
        switch session.stack.getCallStack(_thread)
        {
            case Success(stack):
                switch stack.find(isHaxeFrame)
                {
                    case Haxe(haxe, _):
                        final exnFile = haxe.file.haxe;
                        final exnLine = haxe.expr.haxe.start.line;

                        Sys.println('Thread $_thread has thrown an exception at $exnFile Line $exnLine');

                        final minLine = Std.int(Math.max(1, exnLine - 3)) - 1;
                        final maxLine = exnLine + 3;
                        final input   = File.read(exnFile, false);

                        // Read all lines up until the ones we're actually interested in.
                        var i = 0;
                        while (i < minLine)
                        {
                            input.readLine();
                            i++;
                        }

                        for (i in 0...(maxLine - minLine))
                        {
                            try
                            {
                                final line    = input.readLine();
                                final absLine = minLine + i + 1;

                                if (exnLine == absLine)
                                {
                                    Sys.print('=>\t');
                                }
                                else
                                {
                                    Sys.print('\t');
                                }

                                Sys.println('$absLine: $line');
                            }
                            catch (_ : Eof)
                            {
                                break;
                            }
                        }

                        input.close();
                    case _:
                        Sys.println('exception thrown which contained no haxe frames in thread $_thread');
                }
            case Error(_):
                Sys.println('unable to get the stack for an exception thrown in thread $_thread');
        }
    }

    function isHaxeFrame(_frame : StackFrame)
    {
        return switch _frame
        {
            case Haxe(_, _):
                true;
            case Native(_):
                false;
        }
    }
}