package hxcppdbg.cli;

import tink.CoreApi.Noise;
import tink.CoreApi.Error;
import tink.CoreApi.Promise;
import hxcppdbg.core.Session;

class Hxcppdbg
{
    final session : Session;

    @:command public final breakpoints : Breakpoints;

    @:command public final stack : Stack;

    @:command public final step : Step;

    @:command public final locals : Locals;

    @:command public final eval : Eval;

    public function new(_session)
    {
        session = _session;

        breakpoints = new Breakpoints(session.breakpoints);
        stack       = new Stack(session.stack);
        step        = new Step(session);
        locals      = new Locals(session.locals);
        eval        = new Eval(session.eval);
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
                                case Success(_):
                                    _resolve(null);
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
                                case Success(_):
                                    _resolve(null);
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
        trace('todo : cleanup');

        Sys.exit(0);
    }

    // function printBreakpointHitLocation(_event : BreakpointHit)
    // {
    //     Sys.println('Thread ${ _event.thread } hit breakpoint ${ _event.breakpoint.id } at ${ _event.breakpoint.file } Line ${ _event.breakpoint.line }');

    //     final minLine = Std.int(Math.max(1, _event.breakpoint.line - 3)) - 1;
    //     final maxLine = _event.breakpoint.line + 3;
    //     final input   = File.read(_event.breakpoint.file, false);

    //     // Read all lines up until the ones we're actually interested in.
    //     var i = 0;
    //     while (i < minLine)
    //     {
    //         input.readLine();
    //         i++;
    //     }

    //     for (i in 0...(maxLine - minLine))
    //     {
    //         try
    //         {
    //             final line    = input.readLine();
    //             final absLine = minLine + i + 1;

    //             if (_event.breakpoint.line == absLine)
    //             {
    //                 Sys.print('=>\t');
    //             }
    //             else
    //             {
    //                 Sys.print('\t');
    //             }

    //             Sys.println('$absLine: $line');
    //         }
    //         catch (_ : Eof)
    //         {
    //             break;
    //         }
    //     }

    //     input.close();
    // }

    // function printExceptionLocation(_thread : Int)
    // {
    //     session.stack.getCallStack(_thread, result -> {
    //         switch result
    //         {
    //             case Success(stack):
    //                 switch stack.find(isHaxeFrame)
    //                 {
    //                     case Haxe(haxe, _):
    //                         final exnFile = haxe.file.haxe;
    //                         final exnLine = haxe.expr.haxe.start.line;
    
    //                         Sys.println('Thread $_thread has thrown an exception at $exnFile Line $exnLine');
    
    //                         final minLine = Std.int(Math.max(1, exnLine - 3)) - 1;
    //                         final maxLine = exnLine + 3;
    //                         final input   = File.read(exnFile, false);
    
    //                         // Read all lines up until the ones we're actually interested in.
    //                         var i = 0;
    //                         while (i < minLine)
    //                         {
    //                             input.readLine();
    //                             i++;
    //                         }
    
    //                         for (i in 0...(maxLine - minLine))
    //                         {
    //                             try
    //                             {
    //                                 final line    = input.readLine();
    //                                 final absLine = minLine + i + 1;
    
    //                                 if (exnLine == absLine)
    //                                 {
    //                                     Sys.print('=>\t');
    //                                 }
    //                                 else
    //                                 {
    //                                     Sys.print('\t');
    //                                 }
    
    //                                 Sys.println('$absLine: $line');
    //                             }
    //                             catch (_ : Eof)
    //                             {
    //                                 break;
    //                             }
    //                         }
    
    //                         input.close();
    //                     case _:
    //                         Sys.println('exception thrown which contained no haxe frames in thread $_thread');
    //                 }
    //             case Error(_):
    //                 Sys.println('unable to get the stack for an exception thrown in thread $_thread');
    //         }
    //     });
    // }

    // function isHaxeFrame(_frame : StackFrame)
    // {
    //     return switch _frame
    //     {
    //         case Haxe(_, _):
    //             true;
    //         case Native(_):
    //             false;
    //     }
    // }
}