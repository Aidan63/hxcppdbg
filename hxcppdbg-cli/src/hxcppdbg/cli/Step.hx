package hxcppdbg.cli;

import haxe.Exception;
import hxcppdbg.core.Session;

class Step
{
    final session : Session;

    public var thread = 0;

    public function new(_session)
    {
        session = _session;
    }

    @:defaultCommand('in') public function step()
    {
        session.step(thread, In, result -> {
            switch result
            {
                case Success(Some(interrupt)):
                    switch interrupt
                    {
                        case ExceptionThrown(threadIndex):
                            //
                        case BreakpointHit(threadIndex, id):
                            //
                        case Other:
                            //
                    }
                case Success(None):
                    printLocation();
                case Error(exn):
                    trace(exn.message);
            }
        });
    }

    @:command public function out()
    {
        session.step(thread, Out, result -> {
            switch result
            {
                case Success(Some(interrupt)):
                    switch interrupt
                    {
                        case ExceptionThrown(threadIndex):
                            //
                        case BreakpointHit(threadIndex, id):
                            //
                        case Other:
                            //
                    }
                case Success(None):
                    printLocation();
                case Error(exn):
                    trace(exn.message);
            }
        });
    }

    @:command public function over()
    {
        session.step(thread, Over, result -> {
            switch result
            {
                case Success(Some(interrupt)):
                    switch interrupt
                    {
                        case ExceptionThrown(threadIndex):
                            //
                        case BreakpointHit(threadIndex, id):
                            //
                        case Other:
                            //
                    }
                case Success(None):
                    printLocation();
                case Error(exn):
                    trace(exn.message);
            }
        });
    }

    @:command public function help()
    {
        //
    }

    function printLocation()
    {
        session.stack.getFrame(thread, 0, result -> {
            switch result
            {
                case Success(v):
                    switch v
                    {
                        case Haxe(haxe, _):
                            Sys.println('Thread $thread at ${ haxe.file.haxe } Line ${ haxe.expr.haxe.start.line }');
                        case Native(_):
                            // We should never end up in a native function.
                            // Eventually a native flag might be added which means we could.
                            // We could also step out of the haxe main so maybe we should continue running the program (and check for exit).
                            Sys.println('Location is a native frame');
            
                    }
                case Error(e):
                    Sys.println(e.message);
            }
        });
    }
}