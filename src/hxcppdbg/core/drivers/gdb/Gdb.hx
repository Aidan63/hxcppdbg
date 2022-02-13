package hxcppdbg.core.drivers.gdb;

import hxcppdbg.core.drivers.gdb.Parser.MiParser;
import hxcppdbg.core.drivers.gdb.Parser.AsyncRecord;
import hxcppdbg.core.drivers.gdb.Parser.ResultRecord;
import haxe.Exception;
import sys.io.Process;

class Gdb {
    final proc : Process;

    public function new() {
        proc = new Process('gdb --interpreter=mi');

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
                    // TODO : Better handle this, seems like stdout doesn't conform to the output spec?
                    // trace(string);
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