package hxcppdbg.cli;

import hxcppdbg.core.stack.Stack in CoreStack;

using Lambda;
using StringTools;

class Stack
{
    final driver : CoreStack;

    public var thread = 0;

    public function new(_driver)
    {
        driver = _driver;
    }

    @:command public function list()
    {
        driver.getCallStack(thread);
    }

    @:defaultCommand public function help()
    {
        //
    }

    // final sourcemap : Sourcemap;

    // final process : LLDBProcess;

    // public var native = false;

    // public var thread = 0;

    // public function new(_sourcemap, _process) {
    //     sourcemap = _sourcemap;
    //     process   = _process;
    // }

    // @:command public function list() {
    //     final native = process.getStackFrames(thread);
    //     final frames = native.map(f -> mapNativeFrame(sourcemap, f)).filter(filterFrame);

    //     for (idx => frame in frames) {
    //         switch frame {
    //             case Haxe(file, type, line):
    //                 switch type {
    //                     case Left(func):
    //                         final args = func.arguments.map(a -> a.type).join(',');
    //                         final name = func.name;
    //                         final cls  = file.type;
    //                         Sys.println('\t$idx: $cls.$name($args) Line $line');
    //                     case Right(closure):
    //                         final name = '${ closure.caller }.${ closure.definition.name }';
    //                         final cls  = file.type;
    //                         Sys.println('\t$idx: $cls.$name() Line $line');
    //                 }
    //             case Native(_, type, line):
    //                 Sys.println('\t$idx: [native] $type Line $line');
    //         }
    //     }
    // }
}