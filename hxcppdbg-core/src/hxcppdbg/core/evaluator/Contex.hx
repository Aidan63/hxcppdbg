package hxcppdbg.core.evaluator;

import haxe.Exception;
import hscript.Expr;
import hscript.Parser;
import hscript.Printer;
import hxcppdbg.core.ds.Result;
import hxcppdbg.core.model.Model;
import hxcppdbg.core.model.ModelData;

using Lambda;

class Context
{
    final locals : Array<Model>;

    final parser : Parser;

    final printer : Printer;

    public function new(_locals)
    {
        locals  = _locals;
        parser  = new Parser();
        printer = new Printer();
    }

    public function interpret(_input)
    {
        return try
        {
            Result.Success(eval(parser.parseString(_input)));
        }
        catch (exn)
        {
            Result.Error(exn);
        }
    }

    function eval(_expr : Expr, _context : ModelData = null) : ModelData
    {
        return switch _expr
        {
            case EConst(c):
                switch c
                {
                    case CInt(v):
                        ModelData.MInt(v);
                    case CFloat(f):
                        ModelData.MFloat(f);
                    case CString(s):
                        ModelData.MString(s);
                }
            case EIdent(v):
                return switch locals.find(m -> identity(v, m.key))
                {
                    case null:
                        throw new Exception('no variable with the name "$v"');
                    case found:
                        found.data;
                }
            case EField(e, f):
                switch eval(e, _context)
                {
                    case
                        MMap(children),
                        MDynamic(MMap(children)),
                        MAnon(children),
                        MDynamic(MAnon(children)),
                        MClass(_, children),
                        MDynamic(MClass(_, children)):
                        switch children.find(m -> identity(f, m.key))
                        {
                            case null:
                                throw new Exception('Unable to find "$f" in children');
                            case found:
                                found.data;
                        }
                    case other:
                        throw new Exception('Cannot perform field access on ${ other.getName() }');
                }
            case EBinop(op, e1, e2):
                evalBinop(op, eval(e1), eval(e2));
            case EArray(e, index):
                switch eval(e, _context)
                {
                    case MArray(items):
                        switch eval(index, _context)
                        {
                            case MInt(i), MDynamic(MInt(i)):
                                items[i];
                            default:
                                throw new Exception('Can only index into an array with an integer');
                        }
                    // case MMap(items):
                    //     items.find(m -> keysearch(eval(index), m.key));
                    case MDynamic(inner):
                        eval(e, inner);
                    default:
                        throw new Exception('Can only index on an array or map');
                }
            default:
                throw new Exception('Unsupported expression');
        }
    }

    function evalBinop(_op : String, _e1 : ModelData, _e2 : ModelData)
    {
        return switch _op
        {
            case '+':
                switch _e1
                {
                    case MInt(i1):
                        switch _e2
                        {
                            case MInt(i2):
                                ModelData.MInt(i1 + i2);
                            case MFloat(f2):
                                ModelData.MFloat(i1 + f2);
                            case MString(s2):
                                ModelData.MString('$i1$s2');
                            case MDynamic(inner):
                                evalBinop(_op, _e1, inner);
                            case other:
                                throw new Exception('unable to add ${ other.getName() }');
                        }
                    case MFloat(f1):
                        switch _e2
                        {
                            case MInt(i2):
                                ModelData.MFloat(f1 + i2);
                            case MFloat(f2):
                                ModelData.MFloat(f1 + f2);
                            case MString(s2):
                                ModelData.MString('$f1$s2');
                            case MDynamic(inner):
                                evalBinop(_op, _e1, inner);
                            case other:
                                throw new Exception('unable to add ${ other.getName() }');
                        }
                    case MString(s1):
                        switch _e2
                        {
                            case MInt(i2):
                                ModelData.MString('$s1$i2');
                            case MFloat(f2):
                                ModelData.MString('$s1$f2');
                            case MString(s2):
                                ModelData.MString('$s1$s2');
                            case MDynamic(inner):
                                evalBinop(_op, _e1, inner);
                            case other:
                                throw new Exception('unable to add ${ other.getName() }');
                        }
                    case MDynamic(inner):
                        evalBinop(_op, inner, _e2);
                    case other:
                        throw new Exception('unable to add ${ other.getName() }');
                }
            case '-':
                switch _e1
                {
                    case MInt(i1):
                        switch _e2
                        {
                            case MInt(i2):
                                ModelData.MInt(i1 - i2);
                            case MFloat(f2):
                                ModelData.MFloat(i1 - f2);
                            case MDynamic(inner):
                                evalBinop(_op, _e1, inner);
                            case other:
                                throw new Exception('unable to add ${ other.getName() }');
                        }
                    case MFloat(f1):
                        switch _e2
                        {
                            case MInt(i2):
                                ModelData.MFloat(f1 - i2);
                            case MFloat(f2):
                                ModelData.MFloat(f1 - f2);
                            case MDynamic(inner):
                                evalBinop(_op, _e1, inner);
                            case other:
                                throw new Exception('unable to add ${ other.getName() }');
                        }
                    case MDynamic(inner):
                        evalBinop(_op, inner, _e2);
                    case other:
                        throw new Exception('unable to add ${ other.getName() }');
                }
            case '*':
                switch _e1
                {
                    case MInt(i1):
                        switch _e2
                        {
                            case MInt(i2):
                                ModelData.MInt(i1 * i2);
                            case MFloat(f2):
                                ModelData.MFloat(i1 * f2);
                            case MDynamic(inner):
                                evalBinop(_op, _e1, inner);
                            case other:
                                throw new Exception('unable to add ${ other.getName() }');
                        }
                    case MFloat(f1):
                        switch _e2
                        {
                            case MInt(i2):
                                ModelData.MFloat(f1 * i2);
                            case MFloat(f2):
                                ModelData.MFloat(f1 * f2);
                            case MDynamic(inner):
                                evalBinop(_op, _e1, inner);
                            case other:
                                throw new Exception('unable to add ${ other.getName() }');
                        }
                    case MDynamic(inner):
                        evalBinop(_op, inner, _e2);
                    case other:
                        throw new Exception('unable to add ${ other.getName() }');
                }
            case '/':
                switch _e1
                {
                    case MInt(i1):
                        switch _e2
                        {
                            case MInt(i2):
                                ModelData.MFloat(i1 / i2);
                            case MFloat(f2):
                                ModelData.MFloat(i1 / f2);
                            case MDynamic(inner):
                                evalBinop(_op, _e1, inner);
                            case other:
                                throw new Exception('unable to add ${ other.getName() }');
                        }
                    case MFloat(f1):
                        switch _e2
                        {
                            case MInt(i2):
                                ModelData.MFloat(f1 / i2);
                            case MFloat(f2):
                                ModelData.MFloat(f1 / f2);
                            case MDynamic(inner):
                                evalBinop(_op, _e1, inner);
                            case other:
                                throw new Exception('unable to add ${ other.getName() }');
                        }
                    case MDynamic(inner):
                        evalBinop(_op, inner, _e2);
                    case other:
                        throw new Exception('unable to add ${ other.getName() }');
                }
            case '>':
                switch _e1
                {
                    case MInt(i1):
                        switch _e2
                        {
                            case MInt(i2):
                                ModelData.MBool(i1 > i2);
                            case MFloat(f2):
                                ModelData.MBool(i1 > f2);
                            case MDynamic(inner):
                                evalBinop(_op, _e1, inner);
                            case other:
                                throw new Exception('unable to add ${ other.getName() }');
                        }
                    case MFloat(f1):
                        switch _e2
                        {
                            case MInt(i2):
                                ModelData.MBool(f1 > i2);
                            case MFloat(f2):
                                ModelData.MBool(f1 > f2);
                            case MDynamic(inner):
                                evalBinop(_op, _e1, inner);
                            case other:
                                throw new Exception('unable to add ${ other.getName() }');
                        }
                    case MDynamic(inner):
                        evalBinop(_op, inner, _e2);
                    case other:
                        throw new Exception('unable to add ${ other.getName() }');
                }
            case '<':
                switch _e1
                {
                    case MInt(i1):
                        switch _e2
                        {
                            case MInt(i2):
                                ModelData.MBool(i1 < i2);
                            case MFloat(f2):
                                ModelData.MBool(i1 < f2);
                            case MDynamic(inner):
                                evalBinop(_op, _e1, inner);
                            case other:
                                throw new Exception('unable to add ${ other.getName() }');
                        }
                    case MFloat(f1):
                        switch _e2
                        {
                            case MInt(i2):
                                ModelData.MBool(f1 < i2);
                            case MFloat(f2):
                                ModelData.MBool(f1 < f2);
                            case MDynamic(inner):
                                evalBinop(_op, _e1, inner);
                            case other:
                                throw new Exception('unable to add ${ other.getName() }');
                        }
                    case MDynamic(inner):
                        evalBinop(_op, inner, _e2);
                    case other:
                        throw new Exception('unable to add ${ other.getName() }');
                }
            case '>=':
                switch _e1
                {
                    case MInt(i1):
                        switch _e2
                        {
                            case MInt(i2):
                                ModelData.MBool(i1 >= i2);
                            case MFloat(f2):
                                ModelData.MBool(i1 >= f2);
                            case MDynamic(inner):
                                evalBinop(_op, _e1, inner);
                            case other:
                                throw new Exception('unable to add ${ other.getName() }');
                        }
                    case MFloat(f1):
                        switch _e2
                        {
                            case MInt(i2):
                                ModelData.MBool(f1 >= i2);
                            case MFloat(f2):
                                ModelData.MBool(f1 >= f2);
                            case MDynamic(inner):
                                evalBinop(_op, _e1, inner);
                            case other:
                                throw new Exception('unable to add ${ other.getName() }');
                        }
                    case MDynamic(inner):
                        evalBinop(_op, inner, _e2);
                    case other:
                        throw new Exception('unable to add ${ other.getName() }');
                }
            case '<=':
                switch _e1
                {
                    case MInt(i1):
                        switch _e2
                        {
                            case MInt(i2):
                                ModelData.MBool(i1 <= i2);
                            case MFloat(f2):
                                ModelData.MBool(i1 <= f2);
                            case MDynamic(inner):
                                evalBinop(_op, _e1, inner);
                            case other:
                                throw new Exception('unable to add ${ other.getName() }');
                        }
                    case MFloat(f1):
                        switch _e2
                        {
                            case MInt(i2):
                                ModelData.MBool(f1 <= i2);
                            case MFloat(f2):
                                ModelData.MBool(f1 <= f2);
                            case MDynamic(inner):
                                evalBinop(_op, _e1, inner);
                            case other:
                                throw new Exception('unable to add ${ other.getName() }');
                        }
                    case MDynamic(inner):
                        evalBinop(_op, inner, _e2);
                    case other:
                        throw new Exception('unable to add ${ other.getName() }');
                }
            case '==':
                switch _e1
                {
                    case MInt(i1):
                        switch _e2
                        {
                            case MInt(i2):
                                ModelData.MBool(i1 == i2);
                            case MFloat(f2):
                                ModelData.MBool(i1 == f2);
                            case MDynamic(inner):
                                evalBinop(_op, _e1, inner);
                            case other:
                                throw new Exception('unable to add ${ other.getName() }');
                        }
                    case MFloat(f1):
                        switch _e2
                        {
                            case MInt(i2):
                                ModelData.MBool(f1 == i2);
                            case MFloat(f2):
                                ModelData.MBool(f1 == f2);
                            case MDynamic(inner):
                                evalBinop(_op, _e1, inner);
                            case other:
                                throw new Exception('unable to add ${ other.getName() }');
                        }
                    case MString(s1):
                        switch _e2
                        {
                            case MString(s2):
                                ModelData.MBool(s1 == s2);
                            case MDynamic(inner):
                                evalBinop(_op, _e1, inner);
                            case other:
                                throw new Exception('unable to add ${ other.getName() }');
                        }
                    case MDynamic(inner):
                        evalBinop(_op, inner, _e2);
                    case other:
                        throw new Exception('unable to add ${ other.getName() }');
                }
            case '!=':
                switch _e1
                {
                    case MInt(i1):
                        switch _e2
                        {
                            case MInt(i2):
                                ModelData.MBool(i1 != i2);
                            case MFloat(f2):
                                ModelData.MBool(i1 != f2);
                            case MDynamic(inner):
                                evalBinop(_op, _e1, inner);
                            case other:
                                throw new Exception('unable to add ${ other.getName() }');
                        }
                    case MFloat(f1):
                        switch _e2
                        {
                            case MInt(i2):
                                ModelData.MBool(f1 != i2);
                            case MFloat(f2):
                                ModelData.MBool(f1 != f2);
                            case MDynamic(inner):
                                evalBinop(_op, _e1, inner);
                            case other:
                                throw new Exception('unable to add ${ other.getName() }');
                        }
                    case MString(s1):
                        switch _e2
                        {
                            case MString(s2):
                                ModelData.MBool(s1 != s2);
                            case MDynamic(inner):
                                evalBinop(_op, _e1, inner);
                            case other:
                                throw new Exception('unable to add ${ other.getName() }');
                        }
                    case MDynamic(inner):
                        evalBinop(_op, inner, _e2);
                    case other:
                        throw new Exception('unable to add ${ other.getName() }');
                }
            case other:
                throw new Exception('unsupported binop $other');
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