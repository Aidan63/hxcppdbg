package hxcppdbg.cli;

import hxcppdbg.core.stack.StackFrame;
import hxcppdbg.core.stack.Stack in CoreStack;

using Lambda;
using StringTools;
using EnumValue;

class Stack
{
    final driver : CoreStack;

    public var thread = 0;

    public var all = false;

    public var native = false;

    public function new(_driver)
    {
        driver = _driver;
    }

    @:command public function list()
    {
        switch driver.getCallStack(thread)
        {
            case Success(v):
                for (idx => frame in v.filter(filterFrame))
                {
                    switch frame
                    {
                        case Haxe(haxe, frame):
                            if (native)
                            {
                                Sys.println('\t$idx: [native] ${ frame.func } Line ${ frame.line }');
                            }
                            else
                            {
                                switch haxe.closure
                                {
                                    case Some(closure):
                                        Sys.println('\t$idx: ${ haxe.file.type }.${ haxe.func.name }.${ closure.name }() Line ${ haxe.expr.haxe.start.line }');
                                    case None:
                                        Sys.println('\t$idx: ${ haxe.file.type }.${ haxe.func.name }() Line ${ haxe.expr.haxe.start.line }');
                                }
                            }
                        case Native(frame):
                            Sys.println('\t$idx: [native] ${ frame.func } Line ${ frame.line }');
                    }
                }
            case Error(e):
                Sys.println('\t${ e.message }');
        }
    }

    @:defaultCommand public function help()
    {
        //
    }

    function filterFrame(_stackFrame : StackFrame)
    {
        return switch _stackFrame
        {
            case Haxe(_, _):
                true;
            case Native(_):
                all;
        }
    }
}