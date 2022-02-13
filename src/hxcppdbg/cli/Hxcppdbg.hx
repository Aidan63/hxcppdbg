package hxcppdbg.cli;

import hxcppdbg.core.drivers.lldb.LLDBProcess;
import sys.io.File;
import sys.thread.EventLoop.EventHandler;
import sys.thread.Thread;
import hxcppdbg.core.sourcemap.Sourcemap;
import hxcppdbg.core.drivers.lldb.LLDBObjects;

class Hxcppdbg {
    final thread : Thread;

    final event : EventHandler;

    final sourcemap : Sourcemap;

    final lldb : LLDBObjects;

    final process : LLDBProcess;

    @:command public final breakpoints : Breakpoints;

    @:command public final stack : Stack;

    @:command public final locals : Locals;

    public function new(_thread, _event) {
        thread = _thread;
        event  = _event;

        sourcemap   = new json2object.JsonParser<Sourcemap>().fromJson(File.getContent('/mnt/d/programming/haxe/hxcppdbg/sample_sourcemap.json'));
        lldb        = LLDBObjects.createFromFile('/mnt/d/programming/haxe/hxcppdbg/sample/bin/Main-debug');
        process     = lldb.launch();
        breakpoints = new Breakpoints(sourcemap, lldb);
        stack       = new Stack(sourcemap, process);
        locals      = new Locals(sourcemap, process);
    }

    @:command public function start() {
        process.start(Sys.getCwd());
    }

    @:command public function resume() {
        process.resume();
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