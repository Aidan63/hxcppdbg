package hxcppdbg.core.locals;

import haxe.Exception;
import hxcppdbg.core.model.ModelData;
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

    public function getLocals(_thread, _index, _callback : Result<Array<LocalVariable>, Exception>->Void)
    {
        stack.getFrame(_thread, _index, result -> {
            switch result
            {
                case Success(frame):
                    driver.getVariables(_thread, _index, result -> {
                        switch result
                        {
                            case Success(locals):
                                _callback(Result.Success(locals.map(mapNativeLocal.bind(frame))));
                            case Error(e):
                                _callback(Result.Error(e));
                        }
                    });
                case Error(e):
                    _callback(Result.Error(e));
            }
        });
    }

    function mapNativeLocal(_frame : StackFrame, _native : Model)
    {
        return switch _frame
        {
            case Haxe(haxe, _):
                switch haxe.func.variables.find(v -> isLocalVar(v.cpp, _native))
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

    function isLocalVar(_variable : String, _native : Model)
    {
        return switch _native.key
        {
            case MString(s):
                s == _variable;
            case _:
                false;
        }
    }
}