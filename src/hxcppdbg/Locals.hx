package hxcppdbg;

import haxe.Exception;
import haxe.ds.Either;
import hxcppdbg.gdb.Gdb;
import hxcppdbg.gdb.Parser.Value;
import hxcppdbg.sourcemap.Sourcemap;

using Lambda;
using StringTools;

class Locals {
    final sourcemap : Sourcemap;

    final gdb : Gdb;

    public function new(_sourcemap, _gdb) {
        sourcemap = _sourcemap;
        gdb       = _gdb;
    }

    @:command public function list() {
        final hxFunc = switch gdb.command('-stack-info-frame').results['frame'] {
            case Tuple(values):
                final file = getConstValue(values['file']);
                final func = getConstValue(values['func']);

                switch sourcemap.files.find(v -> file.endsWith(v.generated)) {
                    case null:
                        throw new Exception('Unable to find haxe function for the current frame');
                    case found:
                        final cppType = func.split('::');
                        final objName = '${ found.type }_obj';

                        switch cppType {
                            case [ type, _, '_hx_run' ] if (type == objName):
                                Left(found.closures.find(c -> c.name == cppType[1]));
                            case _:
                                if (cppType.length >= 2 && cppType[cppType.length - 2] == objName) {
                                    Right(found.functions.find(f -> f.cpp == cppType[cppType.length - 1]));
                                } else {
                                    throw new Exception('Unable to find haxe function for the current frame');
                                }
                        }
                }
            case _:
                throw new Exception('Unable to get current frame');
        }

        switch gdb.command('-stack-list-variables 2').results['variables'] {
            case List(Left(values)):
                Sys.println('local vars');
                for (value in values) {
                    switch value {
                        case Tuple(v):
                            final hxVar = switch v['name'] {
                                case null:
                                    throw new Exception('stack variable does not contain a name');
                                case found:
                                    final cppVar = getConstValue(found);

                                    switch hxFunc {
                                        case Left(closure):
                                            closure.captures.find(v -> v.cpp == cppVar);
                                        case Right(func):
                                            func.variables.find(v -> v.cpp == cppVar);
                                    }
                            }

                            if (hxVar != null) {
                                final hxVal = switch v['value'] {
                                    case null:
                                        switch hxVar.type {
                                            case 'String':
                                                getConstValue(gdb.command('-data-evaluate-expression ${ hxVar.cpp }.__CStr()').results['value']);
                                            case _:
                                                '(no value)';
                                        }
                                    case found:
                                        getConstValue(found);
                                }

                                Sys.println('  ${ hxVar.haxe } : ${ hxVar.type } = ${ hxVal }');
                            }
                        case _:
                            //
                    }
                }
            case _:
                //
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
}