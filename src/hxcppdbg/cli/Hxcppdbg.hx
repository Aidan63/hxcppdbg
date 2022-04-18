package hxcppdbg.cli;

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
        session.start();
    }

    @:command public function resume()
    {
        session.resume();
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
}