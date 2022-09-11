package hxcppdbg.cli;

import tink.CoreApi.Noise;
import tink.CoreApi.Error;
import tink.CoreApi.Promise;
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
        return Promise.irreversible((_resolve : Noise->Void, _reject : Error->Void) -> {
            driver.getCallStack(thread, result -> {
                switch result
                {
                    case Success(frames):
                        for (idx => frame in frames.filter(filterFrame))
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
                        _resolve(null);
                    case Error(exn):
                        _reject(new Error('\t${ exn.message }'));
                }
            });
        });
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