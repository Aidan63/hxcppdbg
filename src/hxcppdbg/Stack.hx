package hxcppdbg;

import haxe.Exception;
import hxcppdbg.gdb.Parser.Value;
import hxcppdbg.gdb.Gdb;
import hxcppdbg.sourcemap.Sourcemap;

using Lambda;
using StringTools;

class Stack {
    final sourcemap : Sourcemap;

    final gdb : Gdb;


    public function new(_sourcemap, _gdb) {
        sourcemap = _sourcemap;
        gdb       = _gdb;
    }

    @:command public function list() {
        switch gdb.command('-stack-list-frames').results['stack'] {
            case List(Right(results)):
                for (result in results) {
                    if (result.variable == 'frame') {
                        switch result.value {
                            case Tuple(values):
                                Sys.println(mapNativeFrame(values));
                            case _:
                                //
                        }
                    }
                }
            case _:
                'no stack found';
        }
    }

    @:defaultCommand public function help() {
        //
    }

    function getConstValue(_value : Value) {
        return switch _value {
            case Const(v):
                v;
            case _:
                throw new Exception('value was not a const');
        }
    }

    function mapNativeFrame(_values : Map<String, Value>) {
        final line = Std.parseInt(getConstValue(_values['line']));
        final file = getConstValue(_values['file']);
        final func = getConstValue(_values['func']);

        return switch sourcemap.files.find(v -> file.endsWith(v.generated)) {
            case null:
                '  native frame ($func Line $line)';
            case found:
                final hxExpr  = found.exprs.find(e -> e.cpp.start.line == line);
                final cppType = func.split('::');
                final objName = '${ found.type }_obj';

                switch cppType {
                    // Closure object which contains a haxe anon function.
                    case [ objName, _, '_hx_run' ]:
                        '${ found.type }.${ cppType[1] } Line ${ hxExpr.haxe.start.line }';
                    // Standard haxe function.
                    case [ objName, _ ]:
                        final hxFunc = found.functions.find(f -> f.cpp == cppType[1]).haxe;

                        '${ found.type }.${ hxFunc } Line ${ hxExpr.haxe.start.line }';
                    // Something which cannot be mapped back to haxe code.
                    case _:
                        '  native frame ($func Line $line)';
                }
        }
    }
}