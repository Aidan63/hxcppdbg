package hxcppdbg.cli;

import hxcppdbg.core.Session;

class Hxcppdbg {
    final session : Session;

    @:command public final breakpoints : Breakpoints;

    @:command public final stack : Stack;

    public function new(_session)
    {
        session = _session;

        breakpoints = new Breakpoints(session.breakpoints);
        stack       = new Stack(session.stack);
    }

    @:command public function start() {
        session.driver.start();
    }

    @:command public function resume() {
        session.driver.resume();
    }

    @:command
    public function exit() {
        shutdown();
    }

    @:defaultCommand
    public function help() {
        //
    }

    function shutdown() {
        trace('todo : cleanup');

        Sys.exit(0);
    }
}