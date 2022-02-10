package hxcppdbg;

import haxe.Exception;
import hxcppdbg.gdb.Parser.Value;
import hxcppdbg.gdb.Gdb;
import hxcppdbg.sourcemap.Sourcemap;

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

        for (cls in sourcemap.classes) {
            if (file.endsWith(cls.cppPath)) {
                for (func in cls.functions) {
                    for (mapping in func.mapping) {
                        if (mapping.cpp == line) {
                            return '${ func.name } ${ cls.haxePackage }:${ mapping.haxe }';
                        }
                    }
                }
            }
        }

        return '\tnative frame ($func $file:$line)';
    }
}