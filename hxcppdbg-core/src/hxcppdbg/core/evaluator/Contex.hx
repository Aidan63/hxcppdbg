package hxcppdbg.core.evaluator;

import haxe.Exception;
import hscript.Expr;
import hscript.Parser;
import hscript.Printer;
import hxcppdbg.core.ds.Result;
import hxcppdbg.core.model.ModelData;
import hxcppdbg.core.locals.LocalStore;

using Lambda;

class Context
{
    final locals : LocalStore;

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

    function eval(_expr : Expr)
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
                switch locals.getLocal(v)
                {
                    case Success(data):
                        data;
                    case Error(exn):
                        throw exn;
                }
            case EField(e, f):
                switch eval(e)
                {
                    case MDynamic(MString(s)), MString(s) if (f == 'length'):
                        MInt(s.length);
                    case MDynamic(MArray(children)), MArray(children) if (f == 'length'):
                        MInt(children.length());
                    case MMap(model), MDynamic(MMap(model)) if (f == 'count'):
                        MInt(model.count());
                    case MAnon(children), MDynamic(MAnon(children)), MClass(_, children), MDynamic(MClass(_, children)):
                        return children.field(f);
                    case other:
                        throw new Exception('Cannot perform field access on ${ other.getName() }');
                }
            case EBinop(op, e1, e2):
                evalBinop(op, eval(e1), eval(e2));
            case EArray(e, index):
                switch eval(e)
                {
                    case MDynamic(MArray(items)), MArray(items):
                        switch eval(index)
                        {
                            case MInt(i), MDynamic(MInt(i)):
                                items.at(i);
                            default:
                                throw new Exception('Can only index into an array with an integer');
                        }
                    case MDynamic(MMap(model)), MMap(model):
                        model.value(eval(index));
                    case MDynamic(MEnum(_, _, arguments)), MEnum(_, _, arguments):
                        switch eval(index)
                        {
                            case MInt(i), MDynamic(MInt(i)):
                                arguments.at(i);
                            default:
                                throw new Exception('Can only index into an enum constructors arguments with an integer');
                        }
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

    function keysearch(_key : ModelData, _data : ModelData)
    {
        return switch _key
        {
            case MInt(i1):
                switch _data
                {
                    case MInt(i2):
                        i1 == i2;
                    case MFloat(f2):
                        i1 == f2;
                    default:
                        false;
                }
            case MFloat(f1):
                switch _data
                {
                    case MFloat(f2):
                        f1 == f2;
                    default:
                        false;
                }
            case MBool(b1):
                switch _data
                {
                    case MBool(b2):
                        b1 == b2;
                    default:
                        false;
                }
            case MString(s1):
                switch _data
                {
                    case MString(s2):
                        s1 == s2;
                    default:
                        false;
                }
            case other:
                throw new Exception('${ other.getName() } cannot be used to key a map');
        }
    }
}