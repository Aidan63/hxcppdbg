package hxcppdbg.cli;

import hxcppdbg.core.sourcemap.Sourcemap;
import hxcppdbg.core.drivers.lldb.LLDBObjects;
import haxe.Exception;

using Lambda;
using StringTools;

class Breakpoints {
    final sourcemap : Sourcemap;

    final lldb : LLDBObjects;

    public var target = '';

    public var line = 0;

    public var column = -1;


    public function new(_sourcemap, _lldb) {
        sourcemap = _sourcemap;
        lldb      = _lldb;
    }

    @:command public function add() {
        switch sourcemap.files.find(file -> file.haxe.endsWith(target)) {
            case null:
                throw new Exception('Unable to find file in sourcemap with name $target');
            case file:
                // Find all exprs which fit within the line given.
                // We could have multiple exprs due to anonymous functions.
                final exprs = file.exprs.filter(expr -> line >= expr.haxe.start.line && line <= expr.haxe.end.line);

                if (exprs.length == 0) {
                    throw new Exception('No mapping found for $target:$line');
                }

                // If no column was specified then choose the least specific (larget range) of all found exprs.
                // When a column is specified then choose the least specific of the exprs which fit the column constraint.
                final mapping = if (column == -1) {
                    exprs.sort((e1, e2) -> (e2.haxe.end.line - e2.haxe.start.line) - (e1.haxe.end.line - e1.haxe.start.line));
                    exprs[0];
                } else {
                    // This logic to find the best fitting expr with column info doesn't seem very sound, needs a re-think.
                    final filtered = exprs.filter(expr -> column >= expr.haxe.start.col && column <= expr.haxe.end.col);

                    if (filtered.length == 0) {
                        throw new Exception('No mapping found for $target:$line:$column');
                    }

                    filtered.sort((e1, e2) -> (e2.haxe.end.col - e2.haxe.start.col) - (e1.haxe.end.col - e1.haxe.start.col));
                    filtered[filtered.length - 1];
                }

                lldb.setBreakpoint(file.generated, mapping.cpp.start.line);
        }
    }

    @:defaultCommand public function help() {
        trace('breakpoints help');
    }
}