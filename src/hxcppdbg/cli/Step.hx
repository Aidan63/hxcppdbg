package hxcppdbg.cli;

import haxe.Exception;
import hxcppdbg.core.drivers.lldb.StackConverter;
import hxcppdbg.core.drivers.lldb.LLDBProcess;
import hxcppdbg.core.sourcemap.Sourcemap;
import hxcppdbg.core.stack.StackFrame;

class Step {
    final sourcemap : Sourcemap;

    final process : LLDBProcess;

    public var thread = 0;

    public function new(_sourcemap, _process) {
        sourcemap = _sourcemap;
        process   = _process;
    }

    @:defaultCommand('in')
    public function step() {
        final baseFrame = mapNativeFrame(sourcemap, process.getStackFrame(thread, 0));

        var stepAgain = true;
        var current : StackFrame = null;

        while (stepAgain) {
            stepAgain = switch process.stepIn(thread) {
                case null:
                    false;
                case frame:
                    switch (current = mapNativeFrame(sourcemap, frame)) {
                        case Haxe(currentFile, _, currentLine):
                            switch baseFrame {
                                case Haxe(baseFile, _, baseLine):
                                    currentFile.haxe == baseFile.haxe && currentLine == baseLine;
                                case Native(_, _, _):
                                    // Our base frame shouldn't ever be a non haxe one.
                                    // In the future this might be the case (native breakpoints),
                                    // so we sould correct this down the line.
                                    throw new Exception('');
                            }
                        case Native(_, _, _):
                            true;
                    }
            }
        }

        switch current {
            case Haxe(file, _, line):
                Sys.println('Thread $thread at ${ file.haxe } Line ${ line }');
            case Native(_, _, _):
                // We should never end up in a native function.
                // Eventually a native flag might be added which means we could.
                // We could also step out of the haxe main so maybe we should continue running the program (and check for exit).
                throw new Exception('');
        }
    }

    @:command
    public function out() {
        final baseFrame = mapNativeFrame(sourcemap, process.getStackFrame(thread, 0));

        var stepAgain = true;
        var current : StackFrame = null;

        while (stepAgain) {
            stepAgain = switch process.stepOut(thread) {
                case null:
                    false;
                case frame:
                    switch (current = mapNativeFrame(sourcemap, frame)) {
                        case Haxe(currentFile, _, currentLine):
                            switch baseFrame {
                                case Haxe(baseFile, _, baseLine):
                                    currentFile.haxe == baseFile.haxe && currentLine == baseLine;
                                case Native(_, _, _):
                                    // Our base frame shouldn't ever be a non haxe one.
                                    // In the future this might be the case (native breakpoints),
                                    // so we sould correct this down the line.
                                    throw new Exception('');
                            }
                        case Native(_, _, _):
                            true;
                    }
            }
        }

        switch current {
            case Haxe(file, _, line):
                Sys.println('Thread $thread at ${ file.haxe } Line ${ line }');
            case Native(_, _, _):
                // We should never end up in a native function.
                // Eventually a native flag might be added which means we could.
                // We could also step out of the haxe main so maybe we should continue running the program (and check for exit).
                throw new Exception('');
        }
    }

    @:command
    public function over() {
        final baseFrame = mapNativeFrame(sourcemap, process.getStackFrame(thread, 0));

        var stepAgain = true;
        var current : StackFrame = null;

        while (stepAgain) {
            stepAgain = switch process.stepOver(thread) {
                case null:
                    false;
                case frame:
                    switch (current = mapNativeFrame(sourcemap, frame)) {
                        case Haxe(currentFile, _, currentLine):
                            switch baseFrame {
                                case Haxe(baseFile, _, baseLine):
                                    currentFile.haxe == baseFile.haxe && currentLine == baseLine;
                                case Native(_, _, _):
                                    // Our base frame shouldn't ever be a non haxe one.
                                    // In the future this might be the case (native breakpoints),
                                    // so we sould correct this down the line.
                                    throw new Exception('');
                            }
                        case Native(_, _, _):
                            true;
                    }
            }
        }

        switch current {
            case Haxe(file, _, line):
                Sys.println('Thread $thread at ${ file.haxe } Line ${ line }');
            case Native(_, _, _):
                // We should never end up in a native function.
                // Eventually a native flag might be added which means we could.
                // We could also step out of the haxe main so maybe we should continue running the program (and check for exit).
                throw new Exception('');
        }
    }

    @:command
    public function help() {
        //
    }
}