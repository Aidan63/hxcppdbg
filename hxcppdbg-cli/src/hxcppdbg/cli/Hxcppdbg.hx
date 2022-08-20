package hxcppdbg.cli;

import haxe.io.Eof;
import haxe.ds.Option;
import tink.CoreApi.Noise;
import tink.CoreApi.Error;
import tink.CoreApi.Promise;
import hxcppdbg.core.Session;
import hxcppdbg.core.stack.StackFrame;

using Lambda;

class Hxcppdbg
{
    final session : Session;

    @:command public final breakpoints : Breakpoints;

    @:command public final stack : Stack;

    @:command public final step : Step;

    @:command public final locals : Locals;

    @:command public final eval : Eval;

    @:command public final threads : Threads;

    public function new(_session)
    {
        session = _session;

        breakpoints = new Breakpoints(session.breakpoints);
        stack       = new Stack(session.stack);
        step        = new Step(session);
        locals      = new Locals(session.locals);
        eval        = new Eval(session.eval);
        threads     = new Threads(session.threads);
    }

    @:command public function start()
    {
        return Promise.irreversible((_resolve : Noise->Void, _reject : Error->Void) -> {
            session.start(result -> {
                switch result
                {
                    case Success(run):
                        run(result -> {
                            switch result
                            {
                                case Success(opt):
                                    switch opt
                                    {
                                        case Some(interrupt):
                                            switch interrupt
                                            {
                                                case ExceptionThrown(threadIndex):
                                                    printExceptionLocation(threadIndex, _resolve);
                                                case BreakpointHit(threadIndex, id):
                                                    printBreakpointHitLocation(threadIndex, id);

                                                    _resolve(null);
                                                case Other:
                                                    _resolve(null);
                                            }
                                        case None:
                                            _resolve(null);
                                    }
                                case Error(exn):
                                    _reject(new Error(exn.message));
                            }
                        });
                    case Error(exn):
                        _reject(new Error(exn.message));
                }
            });
        });
    }

    @:command public function resume()
    {
        return Promise.irreversible((_resolve : Noise->Void, _reject : Error->Void) -> {
            session.resume(result -> {
                switch result
                {
                    case Success(run):
                        run(result -> {
                            switch result
                            {
                                case Success(opt):
                                    switch opt
                                    {
                                        case Some(interrupt):
                                            switch interrupt
                                            {
                                                case ExceptionThrown(threadIndex):
                                                    printExceptionLocation(threadIndex, _resolve);
                                                case BreakpointHit(threadIndex, id):
                                                    printBreakpointHitLocation(threadIndex, id);

                                                    _resolve(null);
                                                case Other:
                                                    _resolve(null);
                                            }
                                        case None:
                                            _resolve(null);
                                    }
                                case Error(exn):
                                    _reject(new Error(exn.message));
                            }
                        });
                    case Error(exn):
                        _reject(new Error(exn.message));
                }
            });
        });
    }

    @:command public function pause()
    {
        return Promise.irreversible((_resolve : Noise->Void, _reject : Error->Void) -> {
            session.pause(result -> {
                switch result
                {
                    case Success(_):
                        _resolve(null);
                    case Error(exn):
                        _reject(new Error(exn.message));
                }
            });
        });
    }

    @:command
    public function exit()
    {
        shutdown();
    }

    @:defaultCommand
    public function help()
    {
        //
    }

    function shutdown()
    {
        Sys.exit(0);
    }

    function printBreakpointHitLocation(_threadIndex : Option<Int>, _id : Option<Int>)
    {
        switch _threadIndex
        {
            case Some(idx):
                switch _id
                {
                    case Some(id):
                        switch session.breakpoints.get(id)
                        {
                            case Some(bp):
                                Sys.println('Thread ${ idx } hit breakpoint ${ bp.id } at ${ bp.file } Line ${ bp.line }');

                                final minLine = Std.int(Math.max(1, bp.line - 3)) - 1;
                                final maxLine = bp.line + 3;
                                final input   = sys.io.File.read(bp.file.toString(), false);

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
                
                                        if (bp.line == absLine)
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
                            case None:
                                Sys.println('Unable to get breakpoint for ID $id');
                        }
                    case None:
                        Sys.println('Breakpoint hit with an unknown ID');
                }
            case None:
                Sys.println('Breakpoint hit on an unknown thread');
        }
    }

    function printExceptionLocation(_threadIndex : Option<Int>, _resolve : Noise->Void)
    {
        switch _threadIndex
        {
            case Some(idx):
                session.stack.getCallStack(idx, result -> {
                    switch result
                    {
                        case Success(stack):
                            switch stack.find(isHaxeFrame)
                            {
                                case Haxe(haxe, _):
                                    final exnFile = haxe.file.haxe;
                                    final exnLine = haxe.expr.haxe.start.line;

                                    Sys.println('Thread $idx has thrown an exception at $exnFile Line $exnLine');

                                    final minLine = Std.int(Math.max(1, exnLine - 3)) - 1;
                                    final maxLine = exnLine + 3;
                                    final input   = sys.io.File.read(exnFile.toString(), false);
            
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
                                        catch (_ : haxe.io.Eof)
                                        {
                                            break;
                                        }
                                    }
            
                                    input.close();
                                case _:
                                    Sys.println('exception thrown which contained no haxe frames in thread $idx');
                            }
                        case Error(_):
                            Sys.println('unable to get the stack for an exception thrown in thread $idx');
                    }

                    _resolve(null);
                });
            case None:
                _resolve(null);
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