package hxcppdbg.cli;

import hxcppdbg.core.drivers.lldb.StackConverter;
import hxcppdbg.core.drivers.lldb.LLDBProcess;
import hxcppdbg.core.sourcemap.Sourcemap;

using Lambda;
using StringTools;

class Locals {
    final sourcemap : Sourcemap;

    final lldb : LLDBProcess;

    public var native = false;

    public function new(_sourcemap, _lldb) {
        sourcemap = _sourcemap;
        lldb      = _lldb;
    }

    @:command public function list() {
        final frames = lldb.getStackFrames(0);
        final first  = frames[0];

        switch mapNativeFrame(sourcemap, first) {
            case Haxe(_, type, _):
                switch type {
                    case Left(func):
                        for (variable in lldb.getStackVariables(0, 0)) {
                            switch func.variables.find(v -> v.cpp == variable.name)
                            {
                                case null:
                                    if (native) {
                                        Sys.println('\t${ variable.name }\t\t${ variable.type }\t\t${ variable.value }');
                                    }
                                case found:
                                    Sys.println('\t${ found.haxe }\t\t${ found.type }\t\t${ variable.value }');
                            }
                        }
                    case Right(_):
                        //
                }
            case Native(_, _, _):
                //
        }
    }

    @:defaultCommand public function help() {
        //
    }
}