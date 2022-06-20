package hxcppdbg;

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

        while (true)
        {
            input
                .prompt(PromptType.ofString('hxcppdbg '))
                .handle(cb -> {
                    switch cb
                    {
                        case Success(data):
                            final args = regex.split(data);
            
                            tink.Cli
                                .process(args, new Hxcppdbg(session))
                                .handle(_ -> {});
                        case Failure(failure):
                            failure.throwSelf();
                    }
                });
        }
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
                        //
                }
            case Error(_):
                //
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