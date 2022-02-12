package hxcppdbg;

import sys.io.File;
import sys.thread.EventLoop.EventHandler;
import sys.thread.Thread;
import hxcppdbg.gdb.Gdb;
import hxcppdbg.sourcemap.Sourcemap;

class Hxcppdbg {
    final thread : Thread;

    final event : EventHandler;

    final gdb : Gdb;

    final sourcemap : Sourcemap;

    @:command public final breakpoints : Breakpoints;

    @:command public final stack : Stack;

    @:command public final locals : Locals;

    public function new(_thread, _event) {
        thread = _thread;
        event  = _event;

        sourcemap   = new json2object.JsonParser<Sourcemap>().fromJson(File.getContent('/mnt/d/programming/haxe/hxcppdbg/sample_sourcemap.json'));
        gdb         = new Gdb();
        breakpoints = new Breakpoints(sourcemap, gdb);
        stack       = new Stack(sourcemap, gdb);
        locals      = new Locals(sourcemap, gdb);

        gdb.command('-file-exec-and-symbols /mnt/d/programming/haxe/hxcppdbg/sample/bin/Main-debug');
    }

    @:command public function load() {
        //
    }

    @:command public function start() {
        gdb.start();
    }

    @:command public function suspend() {
        //
    }

    @:command
    public function frame() {
        trace('todo : get the current frame');
    }

    @:command
    public function stacktrace() {
        trace('todo : get the current stacktrace');
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