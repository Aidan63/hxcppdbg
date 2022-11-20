package hxcppdbg.core.evaluator;

import haxe.Exception;
import haxe.ds.Option;
import hxcppdbg.core.ds.Result;
import hxcppdbg.core.stack.Stack;
import hxcppdbg.core.model.ModelData;
import hxcppdbg.core.locals.Locals;
import hxcppdbg.core.evaluator.Contex;
import hxcppdbg.core.sourcemap.Sourcemap;

using Lambda;
using hxcppdbg.core.utils.ResultUtils;

class Evaluator
{
    final locals : Locals;

    final stack : Stack;

    final sourcemap : Sourcemap;

    public function new(_sourcemap, _locals, _stack)
    {
        sourcemap = _sourcemap;
        locals    = _locals;
        stack     = _stack;
    }

    public function evaluate(_expr : String, _thread, _index, _stopReason : Result<StopReason, Exception>, _callback : Result<ModelData, Exception>->Void)
    {
        locals.getLocals(_thread, _index, _result -> {
            switch _result
            {
                case Success(locals):
                    final currentException = switch _stopReason
                    {
                        case Result.Success(ExceptionThrown(_, _thrown)):
                            _thrown;
                        case _:
                            Option.None;
                    }

                    _callback(new Context(locals, currentException).interpret(_expr));
                case Error(e):
                    _callback(Result.Error(e));
            }
        });
    }
}