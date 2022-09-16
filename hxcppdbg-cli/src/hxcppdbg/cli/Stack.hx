package hxcppdbg.cli;

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

    @:command public function list(_prompt : tink.cli.Prompt)
    {
        return
            Promise
                .irreversible((_resolve, _reject) -> {
                    driver.getCallStack(thread, result -> {
                        switch result
                        {
                            case Success(frames):
                                _resolve(frames);
                            case Error(exn):
                                _reject(new Error(exn.message));
                        }
                    });
                })
                .next(frames -> frames.filter(filterFrame).mapi(printFrame).join('\n'))
                .next(_prompt.println);
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

    function printFrame(_idx : Int, _stackFrame : StackFrame)
    {
        return switch _stackFrame
        {
            case Haxe(haxe, frame):
                if (native)
                {
                    '\t$_idx: [native] ${ frame.func } Line ${ frame.line }';
                }
                else
                {
                    switch haxe.closure
                    {
                        case Some(closure):
                            '\t$_idx: ${ haxe.file.type }.${ haxe.func.name }.${ closure.name }() Line ${ haxe.expr.haxe.start.line }';
                        case None:
                            '\t$_idx: ${ haxe.file.type }.${ haxe.func.name }() Line ${ haxe.expr.haxe.start.line }';
                    }
                }
            case Native(frame):
                '\t$_idx: [native] ${ frame.func } Line ${ frame.line }';
        }
    }
}