package hxcppdbg.core.drivers.lldb;

import hxcppdbg.core.stack.StackFrame;
import hxcppdbg.core.sourcemap.Sourcemap;
import hxcppdbg.core.drivers.lldb.LLDBProcess.Frame;

using Lambda;
using StringTools;

function mapNativeFrame(_sourcemap : Sourcemap, _frame : Frame) {
    return switch _sourcemap.files.find(v -> v.generated.endsWith(_frame.file)) {
        case null:
            Native(_frame.file, _frame.func, _frame.line);
        case found:
            switch found.exprs.find(e -> e.cpp.start.line == _frame.line) {
                case null:
                    // if we found a haxe file but could not match to an expression then we've probably hit some
                    // hxcpp c++ macro code (e.g. HX_STACKFRAME generated code).
                    Native(_frame.file, _frame.func, _frame.line);
                case hxExpr:
                    final cppType = constructTypeArray(_frame.symbol);
                    final objName = '${ found.type }_obj';

                    if (cppType[cppType.length - 1] == '_hx_run') {
                        final closureName = cppType[cppType.length - 2];
                        final callingFunc = cppType[cppType.length - 3];
                        final hxClosure   = found.closures.find(f -> f.name == closureName);

                        Haxe(found, Right(new ClosureDefinition(hxClosure, callingFunc)), hxExpr.haxe.start.line);
                    } else {                   
                        if (cppType.length >= 2 && objName.endsWith(cppType[cppType.length - 2])) {
                            // Standard haxe function.
                            final hxFunc = found.functions.find(f -> f.cpp == cppType[cppType.length - 1]);

                            Haxe(found, Left(hxFunc), hxExpr.haxe.start.line);
                        } else {
                            // Something which cannot be mapped back to haxe code.
                            Native(_frame.file, _frame.func, _frame.line);
                        }
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