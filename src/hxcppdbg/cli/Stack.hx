package hxcppdbg.cli;

import hxcppdbg.core.stack.StackFrame;
import hxcppdbg.core.drivers.lldb.LLDBProcess;
import hxcppdbg.core.drivers.lldb.StackConverter;
import hxcppdbg.core.sourcemap.Sourcemap;

using Lambda;
using StringTools;

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
        final native = process.getStackFrames(thread);
        final frames = native.map(f -> mapNativeFrame(sourcemap, f)).filter(filterFrame);

        for (idx => frame in frames) {
            switch frame {
                case Haxe(file, type, line):
                    switch type {
                        case Left(func):
                            final args = func.arguments.map(a -> a.type).join(',');
                            final name = func.haxe;
                            final cls  = file.type;
                            Sys.println('\t$idx: $cls.$name($args) Line $line');
                        case Right(closure):
                            final name = '${ closure.caller }.${ closure.definition.name }';
                            final cls  = file.type;
                            Sys.println('\t$idx: $cls.$name() Line $line');
                    }
                case Native(_, type, line):
                    Sys.println('\t$idx: [native] $type Line $line');
            }
        }
    }

    @:defaultCommand public function help() {
        //
    }

    function filterFrame(_frame : StackFrame) {
        return switch _frame {
            case Haxe(_, _, _):
                true;
            case Native(_, _, _):
                native;
        }
    }
}