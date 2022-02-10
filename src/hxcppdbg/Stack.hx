package hxcppdbg;

import haxe.Exception;
import hxcppdbg.gdb.Parser.Value;
import hxcppdbg.gdb.Gdb;
import hxcppdbg.sourcemap.Sourcemap;

using Lambda;
using StringTools;

enum StackFrame {
    Haxe(file : String, type : String, func : String, line : Int);
    Native(file : String, type : String, line : Int);
}

class Stack {
    final sourcemap : Sourcemap;

    final gdb : Gdb;

    public var native = false;

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
                                switch mapNativeFrame(values) {
                                    case Haxe(_, type, func, line):
                                        Sys.println('$type.$func Line $line');
                                    case Native(_, type, line) if (native):
                                        Sys.println('  (native) $type Line $line');
                                    case _:
                                        //
                                }
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
                Native(file, func, line);
            case found:
                final hxExpr  = found.exprs.find(e -> e.cpp.start.line == line);
                final cppType = func.split('::');
                final objName = '${ found.type }_obj';

                switch cppType {
                    // Closure object which contains a haxe anon function.
                    case [ type, _, '_hx_run' ] if (type == objName):
                        Haxe(found.haxe, found.type, cppType[1], hxExpr.haxe.start.line);
                    // Standard haxe function.
                    case [ type, _ ] if (type == objName):
                        final hxFunc = found.functions.find(f -> f.cpp == cppType[1]).haxe;

                        Haxe(found.haxe, found.type, hxFunc, hxExpr.haxe.start.line);
                    // Something which cannot be mapped back to haxe code.
                    case _:
                        Native(file, func, line);
                }
        }
    }
}