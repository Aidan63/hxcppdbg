package hxcppdbg.core.locals;

import hxcppdbg.core.stack.StackFrame;
import hxcppdbg.core.stack.Stack;
import hxcppdbg.core.sourcemap.Sourcemap;
import hxcppdbg.core.drivers.ILocals;

using Lambda;

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
        final frame  = stack.getFrame(_thread, _index);
        final hxVars = driver.getVariables(_thread, _index).map(mapNativeLocal.bind(frame));

        return hxVars;
    }

    function mapNativeLocal(_frame : StackFrame, _native : NativeLocal)
    {
        return switch _frame
        {
            case Haxe(haxe, _):
                switch haxe.func.variables.find(v -> v.cpp == _native.name)
                {
                    case null:
                        LocalVariable.Native(_native);
                    case found:
                        LocalVariable.Haxe(found, _native);
                }
            case Native(_):
                LocalVariable.Native(_native);
        }
    }
}