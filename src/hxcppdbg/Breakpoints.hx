package hxcppdbg;

import hxcppdbg.gdb.Gdb;
import hxcppdbg.sourcemap.Sourcemap;

using Lambda;
using StringTools;

class Breakpoints {
    final sourcemap : Sourcemap;

    final gdb : Gdb;

    public var target : String = '';

    public var line : Int = 0;


    public function new(_sourcemap, _gdb) {
        sourcemap = _sourcemap;
        gdb       = _gdb;
    }

    @:command public function add() {
        switch sourcemap.classes.find(cls -> cls.haxePackage.endsWith(target))
        {
            case null:
                trace('unable to find haxe class with the package $target');
            case foundClass:
                for (func in foundClass.functions) {
                    for (map in func.mapping) {
                        if (map.haxe == line) {
                            trace('add breakpoint at ${ foundClass.cppPath }:${ map.cpp }');

                            final r = gdb.command('-break-insert ${ foundClass.cppPath }:${ map.cpp }');
                            
                            trace(r.cls, r.results);

                            return;
                        }
                    }
                }

                trace('unable to find cpp mapping for haxe line $line');
        }
    }

    @:defaultCommand public function help() {
        trace('breakpoints help');
    }
}