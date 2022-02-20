package hxcppdbg.cli;

import sys.io.File;
import hxcppdbg.core.sourcemap.Sourcemap;
import hxcppdbg.core.drivers.lldb.LLDBObjects;
import haxe.Exception;
import haxe.io.Eof;

using Lambda;
using StringTools;

class Breakpoints {
    final breakpoints : Map<Int, BreakpointLocation>;

    @:command public final add : Add;

    @:command public final remove : Remove;

    public function new(_sourcemap, _lldb) {
        breakpoints = [];
        add         = new Add(_sourcemap, _lldb, breakpoints);
        remove      = new Remove(_lldb, breakpoints);
    }

    @:defaultCommand public function help() {
        Sys.println(tink.Cli.getDoc(this));
    }

    @:command public function list() {
        for (id => breakpoint in breakpoints) {
            final end = if (breakpoint.char != 0) 'Character ${ breakpoint.char }' else '';

            Sys.println('[$id] ${ breakpoint.file } Line ${ breakpoint.line } ${ end }');
        }
    }
}

class Add {
    final sourcemap : Sourcemap;

    final lldb : LLDBObjects;

    final breakpoints : Map<Int, BreakpointLocation>;

    public var file : String;

    public var line : Null<Int>;

    public var char = 0;

    public function new(_sourcemap, _lldb, _breakpoints) {
        sourcemap   = _sourcemap;
        lldb        = _lldb;
        breakpoints = _breakpoints;

        lldb.onBreakpointHitCallback = (_breakpoint, _thread) -> {
            switch breakpoints[_breakpoint] {
                case null:
                    trace('could not find breakpoint');
                case location:
                    Sys.println('Thread $_thread hit breakpoint $_breakpoint at ${ location.file } Line ${ location.line }');

                    final minLine = Std.int(Math.max(1, location.line - 3)) - 1;
                    final maxLine = location.line + 3;
                    final input   = File.read(location.file, false);

                    // Read all lines up until the ones we're actually interested in.
                    var i = 0;
                    while (i < minLine) {
                        input.readLine();
                        i++;
                    }

                    for (i in 0...(maxLine - minLine)) {
                        try {
                            final line    = input.readLine();
                            final absLine = minLine + i + 1;

                            if (location.line == absLine) {
                                Sys.print('=>\t');
                            } else {
                                Sys.print('\t');
                            }

                            Sys.println('$absLine: $line');
                        } catch (_ : Eof) {
                            break;
                        }
                    }

                    input.close();
            }
        }
    }

    @:defaultCommand public function run() {
        switch sourcemap.files.find(f -> f.haxe.endsWith(file)) {
            case null:
                Sys.println('Unable to find file in sourcemap with name $file');
            case file:
                // Find all exprs which fit within the line given.
                // We could have multiple exprs due to anonymous functions.
                final exprs = file.exprs.filter(expr -> line >= expr.haxe.start.line && line <= expr.haxe.end.line);

                if (exprs.length == 0) {
                    Sys.println('unable to find a haxe expression at $file:$line');

                    return;
                }

                // If no column was specified then choose the least specific (larget range) of all found exprs.
                // When a column is specified then choose the least specific of the exprs which fit the column constraint.
                final mapping = if (char == 0) {
                    exprs.sort((e1, e2) -> (e2.haxe.end.line - e2.haxe.start.line) - (e1.haxe.end.line - e1.haxe.start.line));
                    exprs[0];
                } else {
                    // This logic to find the best fitting expr with column info doesn't seem very sound, needs a re-think.
                    final filtered = exprs.filter(expr -> char >= expr.haxe.start.col && char <= expr.haxe.end.col);

                    if (filtered.length == 0) {
                        Sys.println('unable to map $file:$line:$char to a c++ line');

                        return;
                    }

                    filtered.sort((e1, e2) -> (e2.haxe.end.col - e2.haxe.start.col) - (e1.haxe.end.col - e1.haxe.start.col));
                    filtered[filtered.length - 1];
                }

                switch lldb.setBreakpoint(file.cpp, mapping.cpp)
                {
                    case null:
                        Sys.println('unable to set breakpoint');
                    case id:
                        breakpoints.set(id, new BreakpointLocation(file.haxe, mapping.haxe.start.line, if (char != 0) mapping.haxe.start.col else 0));

                        Sys.println('breakpoint $id set');
                }
        }
    }
}

class Remove {
    final lldb : LLDBObjects;

    final breakpoints : Map<Int, BreakpointLocation>;

    public var id : Null<Int>;

    public function new(_lldb, _breakpoints) {
        lldb        = _lldb;
        breakpoints = _breakpoints;
    }

    @:defaultCommand public function run() {
        if (breakpoints.exists(id)) {
            if (lldb.removeBreakpoint(id)) {
                breakpoints.remove(id);

                Sys.println('Breakpoint removed');
            } else {
                Sys.println('Unable to remove breakpoint $id');
            }
        } else {
            Sys.println('breakpoint $id does not exist');
        }

    }
}

private class BreakpointLocation {
    public final file : String;

    public final line : Int;

    public final char : Int;

    public function new(_file, _line, _char) {
        file = _file;
        line = _line;
        char = _char;
    }
}