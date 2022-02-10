package hxcppdbg;

import hxcppdbg.gdb.Parser.Value;
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

    public function new(_thread, _event) {
        thread = _thread;
        event  = _event;

        sourcemap   = new json2object.JsonParser<Sourcemap>().fromJson(File.getContent('/mnt/d/programming/haxe/hxcppdbg/sample_sourcemap.json'));
        gdb         = new Gdb();
        breakpoints = new Breakpoints(sourcemap, gdb);
        stack       = new Stack(sourcemap, gdb);

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

    // function readGdbOutput(_input : Input) {
    //     while (true) {
    //         final line   = _input.readLine();
    //         final buffer = new StringBuf();
    //         buffer.add(line);
    //         buffer.addChar('\n'.code);

    //         if (StringTools.startsWith(line, '(gdb)')) {
    //             break;
    //         } else {
    //             final string = buffer.toString();
    //             final parser = new MiParser(string);

    //             switch parser.parseLine() {
    //                 case Left(v):
    //                     switch v {
    //                         case Async(a):
    //                             switch a.output {
    //                                 case Exec:
    //                                     Sys.println('exec : ${ a.cls } ${ a.results }');
    //                                 case _:
    //                             }
    //                         case Stream(s):
    //                             switch s.output {
    //                                 case Console:
    //                                     // Sys.print(s.value);
    //                                 case _:
    //                                     //
    //                             }
    //                     }
    //                 case Right(v):
    //                     Sys.println('result ${ v.cls }-${ v.results }');
    //             }
    //         }
    //     }
    // }
}