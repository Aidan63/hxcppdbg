package hxcppdbg.cli;

import hxcppdbg.core.DebugSession;
import sys.thread.Thread;
import sys.thread.EventLoop.EventHandler;

class Hxcppdbg {
    final thread : Thread;

    final event : EventHandler;

    final session : DebugSession;

    @:command public final breakpoints : Breakpoints;

    public function new(_thread, _event, _session)
    {
        thread  = _thread;
        event   = _event;
        session = _session;

        breakpoints = new Breakpoints(session.breakpoints);
    }

    @:command public function start() {
        session.driver.start();
    }

    @:command public function resume() {
        session.driver.resume();
    }

    @:command
    public function exit() {
        thread.events.cancel(event);
        thread.events.run(shutdown);
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