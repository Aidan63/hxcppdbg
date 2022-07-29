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
        // switch session.step(thread, In)
        // {
        //     case Error(e):
        //         Sys.println(e.message);
        //     case Success(Natural):
        //         printLocation();
        //     case _:
        //     //
        // }
    }

    @:command public function out()
    {
        // switch session.step(thread, Out)
        // {
        //     case Error(e):
        //         Sys.println(e.message);
        //     case Success(Natural):
        //         printLocation();
        //     case _:
        //         //
        // }
    }

    @:command public function over()
    {
        // switch session.step(thread, Over)
        // {
        //     case Error(e):
        //         Sys.println(e.message);
        //     case Success(Natural):
        //         printLocation();
        //     case _:
        //         //
        // }
    }

    @:command public function help()
    {
        //
    }

    function printLocation()
    {
        switch session.stack.getFrame(thread, 0)
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
    }
}