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

    public var thread = 0;

    public function new(_sourcemap, _process) {
        sourcemap = _sourcemap;
        process   = _process;
    }

    @:command public function list() {
        final frames = process.getStackFrames(thread);
        
        var idx = 1;
        for (frame in frames) {
            switch mapNativeFrame(frame) {
                case Haxe(_, type, func, args, line):
                    Sys.println('\t${ idx++ }: $type.$func(${ args.join(',') }) Line $line');
                case Native(_, type, line) if (native):
                    Sys.println('\t${ idx++ }: (native) $type Line $line');
                case _:
                    // Do not print native frames if the native flag is not set.
            }
        }
    }

    @:defaultCommand public function help() {
        //
    }

    function mapNativeFrame(_frame : Frame) {
        return switch sourcemap.files.find(v -> v.generated.endsWith(_frame.file)) {
            case null:
                Native(_frame.file, _frame.func, _frame.line);
            case found:
                final hxExpr  = found.exprs.find(e -> e.cpp.start.line == _frame.line);
                final cppType = constructTypeArray(_frame.symbol);
                final objName = '${ found.type }_obj';

                if (cppType[cppType.length - 1] == '_hx_run') {
                    final closureName = cppType[cppType.length - 2];
                    final callingFunc = cppType[cppType.length - 3];
                    Haxe(found.haxe, found.type, '$callingFunc.$closureName', [], hxExpr.haxe.start.line);
                } else {                   
                    if (cppType.length >= 2 && objName.endsWith(cppType[cppType.length - 2])) {
                        // Standard haxe function.
                        final hxFunc = found.functions.find(f -> f.cpp == cppType[cppType.length - 1]);
                        final hxArgs = hxFunc.arguments.map(a -> a.type);

                        Haxe(found.haxe, found.type, hxFunc.haxe, hxArgs, hxExpr.haxe.start.line);
                    } else {
                        // Something which cannot be mapped back to haxe code.
                        Native(_frame.file, _frame.func, _frame.line);
                    }
                }
        }
    }

    function constructTypeArray(_symbol : String) {
        final parts = _symbol.split('::');
        final out = parts.map(f -> {
            final idx  = f.indexOf('(');

            if (idx != -1) {
                f.substring(0, idx);
            } else {
                f;
            }
        });

        return out;
    }
}