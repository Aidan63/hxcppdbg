package hxcppdbg.gdb;

import hxcppdbg.gdb.Parser.AsyncRecord;
import haxe.Exception;
import hxcppdbg.gdb.Parser.MiParser;
import hxcppdbg.gdb.Parser.ResultRecord;
import sys.io.Process;
import sys.thread.Thread;
import sys.thread.EventLoop.EventHandler;
import sys.thread.Deque;
import haxe.io.Eof;

class Gdb {
    final proc : Process;

    final result : Deque<ResultRecord>;

    // final thread : Thread;

    // final event : EventHandler;

    public function new() {
        proc   = new Process('gdb --interpreter=mi');
        result = new Deque();
        // thread = Thread.createWithEventLoop(processGdbOutput);
        // event  = thread.events.repeat(processGdbOutput, 0);

        while (!StringTools.startsWith(proc.stdout.readLine(), '(gdb)')) {
            //
        }
    }

    public function start() {
        command('-exec-run');

        var result : AsyncRecord = null;
        while (true) {
            final line   = proc.stdout.readLine();
            final buffer = new StringBuf();
            buffer.add(line);
            buffer.addChar('\n'.code);

            if (StringTools.startsWith(line, '(gdb)')) {
                return result;
            } else {
                final string = buffer.toString();
                final parser = new MiParser(string);

                try {
                    switch parser.parseLine() {
                        case Left(v):
                            switch v {
                                case Async(a):
                                    switch a.output {
                                        case Exec:
                                            result = a;
                                        case _:
                                            Sys.println('${ a.output } : ${ a.cls } ${ a.results }');
                                    }
                                    
                                case Stream(s):
                                    Sys.print('${ s.output } : ${ s.value }');
                            }
                        case Right(v):
                            //

                    }
                } catch (_) {
                    trace(string);
                }
            }
        }
    }

    public function command(_cmd) {
        proc.stdin.writeString('$_cmd\n');

        var result : ResultRecord = null;
        while (true) {
            final line   = proc.stdout.readLine();
            final buffer = new StringBuf();
            buffer.add(line);
            buffer.addChar('\n'.code);

            if (StringTools.startsWith(line, '(gdb)')) {
                return result;
            } else {
                final string = buffer.toString();
                final parser = new MiParser(string);

                trace(string);

                switch parser.parseLine() {
                    case Left(v):
                        switch v {
                            case Async(a):
                                Sys.println('${ a.output } : ${ a.cls } ${ a.results }');
                            case Stream(s):
                                Sys.print('${ s.output } : ${ s.value }');
                        }
                    case Right(v):
                        result = v;
                }
            }
        }
    }
}