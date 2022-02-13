package hxcppdbg.cli;

import hxcppdbg.core.drivers.lldb.LLDBProcess;
import hxcppdbg.core.sourcemap.Sourcemap;

using Lambda;
using StringTools;

enum StackFrame {
    Haxe(file : String, type : String, func : String, args : Array<String>, line : Int);
    Native(file : String, type : String, line : Int);
}

class Stack {
    final sourcemap : Sourcemap;

    final process : LLDBProcess;

    public var native = false;

    public function new(_sourcemap, _process) {
        sourcemap = _sourcemap;
        process   = _process;
    }

    @:command public function list() {
        // switch gdb.command('-stack-list-frames').results['stack'] {
        //     case List(Right(frames)):
        //         Sys.println('stack');
        //         for (frame in frames) {
        //             switch frame.value {
        //                 case Tuple(values):
        //                     switch mapNativeFrame(values) {
        //                         case Haxe(_, type, func, args, line):
        //                             Sys.println('  $type.$func(${ args.join(',') }) Line $line');
        //                         case Native(_, type, line) if (native):
        //                             Sys.println('    (native) $type Line $line');
        //                         case _:
        //                             // Do not print native frames if the native flag is not set.
        //                     }
        //                 case _:
        //                     //
        //             }
        //         }
        //     case _:
        //         'no stack found';
        // }
    }

    @:defaultCommand public function help() {
        //
    }

    // function getConstValue(_value : Value) {
    //     return switch _value {
    //         case Const(v):
    //             v;
    //         case _:
    //             throw new Exception('value was not a const');
    //     }
    // }

    // function mapNativeFrame(_values : Map<String, Value>) {
    //     final line = Std.parseInt(getConstValue(_values['line']));
    //     final file = getConstValue(_values['file']);
    //     final func = getConstValue(_values['func']);

    //     return switch sourcemap.files.find(v -> file.endsWith(v.generated)) {
    //         case null:
    //             Native(file, func, line);
    //         case found:
    //             final hxExpr  = found.exprs.find(e -> e.cpp.start.line == line);
    //             final cppType = func.split('::');
    //             final objName = '${ found.type }_obj';

    //             switch cppType {
    //                 // Closure object which contains a haxe anon function.
    //                 case [ type, _, '_hx_run' ] if (type == objName):
    //                     Haxe(found.haxe, found.type, cppType[1], [], hxExpr.haxe.start.line);
    //                 case _:
    //                     if (cppType.length >= 2 && cppType[cppType.length - 2] == objName) {
    //                         // Standard haxe function.
    //                         final hxFunc = found.functions.find(f -> f.cpp == cppType[cppType.length - 1]);
    //                         final hxArgs = hxFunc.arguments.map(a -> a.type);

    //                         Haxe(found.haxe, found.type, hxFunc.haxe, hxArgs, hxExpr.haxe.start.line);
    //                     } else {
    //                         // Something which cannot be mapped back to haxe code.
    //                         Native(file, func, line);
    //                     }
    //             }
    //     }
    // }
}