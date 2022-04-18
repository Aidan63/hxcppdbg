package hxcppdbg.core.evaluator;

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

class Evaluator
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

    public function evaluate(_expr : String, _thread, _index)
    {
        return switch driver.getVariables(_thread, _index)
        {
            case Success(locals):
                final parser = new hscript.Parser();
                final ast    = parser.parseString(_expr);

                switch fetch(locals, ast)
                {
                    case Success(v):
                        Result.Success(v);
                    case Error(e):
                        Result.Error(e);
                }
            case Error(e):
                Result.Error(e);
        }
    }

    function fetch(_models : Array<Model>, _expr : hscript.Expr)
    {
        return switch _expr
        {
            case EIdent(v):
                switch _models.find(m -> identity(v, m.key))
                {
                    case null:
                        Result.Error(new Exception('unable to find local variable with name $v'));
                    case found:
                        Result.Success(found.data);
                }
            case EField(e, f):
                switch fetch(_models, e)
                {
                    case Success(data):
                        switch data
                        {
                            case MMap(items):
                                switch items.find(m -> identity(f, m.key))
                                {
                                    case null:
                                        Result.Error(new Exception('no item with key $data found in map'));
                                    case found:
                                        Result.Success(found.data);
                                }
                            case MAnon(fields):
                                switch fields.find(m -> identity(f, m.key))
                                {
                                    case null:
                                        Result.Error(new Exception('no item with key $f found in object'));
                                    case found:
                                        Result.Success(found.data);
                                }
                            case MClass(cls, fields):
                                switch fields.find(m -> identity(f, m.key))
                                {
                                    case null:
                                        Result.Error(new Exception('no item with key $f found in class $cls'));
                                    case found:
                                        Result.Success(found.data);
                                }
                            case other:
                                Result.Error(new Exception('field access on ${ other.getName() } is not allowed'));
                        }
                    case Error(e):
                        Result.Error(e);
                }
            case EArray(e, index):
                switch fetch(_models, e)
                {
                    case Success(v):
                        switch v
                        {
                            case MArray(items):
                                switch index
                                {
                                    case EConst(CInt(v)):
                                        Result.Success(items[v]);
                                    case _:
                                        Result.Error(new Exception('Only integer liters are supported for array indexing'));
                                }
                            case other:
                                Result.Error(new Exception('Cannot index onto ${ other.getName() }'));
                        }
                    case Error(e):
                        Result.Error(e);
                }
            case other:
                Result.Error(new Exception('unsupported expression ${ other.getName() }'));
        }
    }

    function identity(_key : String, _model : ModelData)
    {
        return switch _model
        {
            case MString(s):
                s == _key;
            case _:
                false;
        }
    }
}