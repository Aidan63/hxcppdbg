package hxcppdbg.core.locals;

import hxcppdbg.core.model.Model;
import hxcppdbg.core.ds.Result;
import hxcppdbg.core.stack.StackFrame;
import hxcppdbg.core.stack.Stack;
import hxcppdbg.core.sourcemap.Sourcemap;
import hxcppdbg.core.drivers.ILocals;

using Lambda;
using hxcppdbg.core.utils.ResultUtils;

class Locals
{
    final driver : ILocals;

    final stack : Stack;

    final sourcemap : Sourcemap;

    public function new(_sourcemap, _driver, _stack)
    {
        sourcemap = _sourcemap;
        driver    = _driver;
        stack     = _stack;
    }

    public function getLocals(_thread, _index)
    {
        return switch stack.getFrame(_thread, _index)
        {
            case Success(frame):
                driver.getVariables(_thread, _index).map(mapNativeLocal.bind(frame));
            case Error(e):
                Result.Error(e);
        }
    }

    function mapNativeLocal(_frame : StackFrame, _native : Model)
    {
        return switch _frame
        {
            case Haxe(haxe, _):
                switch haxe.func.variables.find(v -> v.cpp == _native.name)
                {
                    case null:
                        LocalVariable.Native(_native);
                    case _:
                        LocalVariable.Haxe(_native);
                }
            case Native(_):
                LocalVariable.Native(_native);
        }
    }
}