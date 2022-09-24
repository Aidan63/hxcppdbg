package hxcppdbg.core.evaluator;

import hscript.Expr;
import haxe.Exception;
import hxcppdbg.core.model.ModelData;
import hxcppdbg.core.model.Model;
import hxcppdbg.core.ds.Result;
import hxcppdbg.core.stack.StackFrame;
import hxcppdbg.core.stack.Stack;
import hxcppdbg.core.evaluator.Contex;
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

    public function evaluate(_expr : String, _thread, _index, _callback : Result<ModelData, Exception>->Void)
    {
        driver.getVariables(_thread, _index, _result -> {
            switch _result
            {
                case Success(locals):
                    _callback(new Context(locals).interpret(_expr));
                case Error(e):
                    _callback(Result.Error(e));
            }
        });
    }

    function fetch(_models : Array<Model>, _expr : hscript.Expr)
    {
        return switch _expr
        {
            case EIdent(v), EConst(CString(v)):
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
                                        if (v < 0 || v >= items.length)
                                        {
                                            Result.Error(new Exception('Index outside of array range'));
                                        }
                                        else
                                        {
                                            Result.Success(items[v]);
                                        }
                                    case _:
                                        Result.Error(new Exception('Only integer liters are supported for array indexing'));
                                }
                            case MMap(items):
                                switch items.find(m -> keysearch(index, m.key))
                                {
                                    case null:
                                        switch index
                                        {
                                            case EConst(CInt(v)):
                                                // Fallback array access by indexing, useful for object maps
                                                if (v < 0 || v >= items.length)
                                                {
                                                    Result.Error(new Exception('Index outside of array range'));
                                                }
                                                else
                                                {
                                                    Result.Success(items[v].data);
                                                }
                                            case _:
                                                Result.Error(new Exception('Unable to find item with key $index'));
                                        }
                                    case model:
                                        Result.Success(model.data);
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

    function keysearch(_key : hscript.Expr, _data : ModelData)
    {
        return switch _key
        {
            case EConst(c):
                switch c
                {
                    case CInt(v):
                        switch _data
                        {
                            case MInt(i):
                                v == i;
                            case MFloat(f):
                                v == f;
                            case _:
                                false;
                        }
                    case CFloat(v):
                        switch _data
                        {
                            case MFloat(f):
                                v == f;
                            case _:
                                false;
                        }
                    case CString(v):
                        switch _data
                        {
                            case MString(s):
                                v == s;
                            case _:
                                false;
                        }
                }
            case EIdent('true'):
                switch _data
                {
                    case MBool(true):
                        true;
                    case _:
                        false;
                }
            case EIdent('false'):
                switch _data
                {
                    case MBool(false):
                        true;
                    case _:
                        false;
                }
            case other:
                false;
        }
    }
}