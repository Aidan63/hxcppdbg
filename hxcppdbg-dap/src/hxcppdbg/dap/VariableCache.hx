package hxcppdbg.dap;

import haxe.Exception;
import hxcppdbg.core.ds.Result;
import hxcppdbg.core.locals.LocalStore;
import tink.CoreApi.Lazy;
import hxcppdbg.core.sourcemap.Sourcemap.GeneratedType;
import haxe.ds.Option;
import hxcppdbg.core.model.Model;
import hxcppdbg.core.model.ModelData;
import hxcppdbg.core.locals.LocalVariable;
import hxcppdbg.dap.protocol.data.Variable;

using Lambda;

class VariableCache
{
    final scopes : Map<Int, LocalStore>;

    final models : Map<Int, ModelData>;

    var index : Int;

    public function new()
    {
        scopes = [];
        models = [];
        index  = 1;
    }

    public function createScope(_locals : LocalStore)
    {
        final id = index++;

        scopes[id] = _locals;

        return id;
    }

    public function fetch(_id : Int, _start : Null<Int>, _count : Null<Int>) : Result<Array<Variable>, Exception>
    {
        return switch scopes[_id]
        {
            case null:
                switch models[_id]
                {
                    case null:
                        Result.Error(new Exception('Failed to find model in storage'));
                    case MNull, MInt(_), MFloat(_), MBool(_), MString(_), MUnknown(_), MDynamic(_):
                        Result.Error(new Exception('Model does not have children'));
                    case MArray(model):
                        final start  = if (_start == null) 0 else _start;
                        final count  = if (_count == null) model.length() else _count;
                        final output = new Array<Variable>();

                        if (start >= model.length() || start + count > model.length())
                        {
                            return Result.Error(new Exception('request out of range of child count'));
                        }

                        for (idx => model in [ for (i in start...(start + count)) model.at(i) ])
                        {
                            output.push({
                                variablesReference: addModel(model),
                                name  : Std.string(start + idx),
                                type  : dataType(model),
                                value : dataValue(model)
                            });

                            switch model
                            {
                                case MArray(model):
                                    output[idx].indexedVariables = model.length();
                                case MMap(model):
                                    output[idx].namedVariables = model.count();
                                case MEnum(_, _, arguments):
                                    output[idx].indexedVariables = arguments.count();
                                case MAnon(model):
                                    output[idx].namedVariables = model.count();
                                case MClass(type, model):
                                    output[idx].namedVariables = model.count();
                                case _:
                            }
                        }
                        
                        Result.Success(output);
                    case MMap(model):
                        Result.Success([]);
                    case MEnum(_, _, arguments):
                        final start  = if (_start == null) 0 else _start;
                        final count  = if (_count == null) arguments.count() else _count;
                        final output = new Array<Variable>();

                        if (start >= arguments.count() || start + count > arguments.count())
                        {
                            return Result.Error(new Exception('request out of range of child count'));
                        }

                        for (idx => model in [ for (i in start...(start + count)) arguments.at(i) ])
                        {
                            output.push({
                                variablesReference: addModel(model),
                                name  : Std.string(start + idx),
                                type  : dataType(model),
                                value : dataValue(model)
                            });

                            switch model
                            {
                                case MArray(model):
                                    output[idx].indexedVariables = model.length();
                                case MMap(model):
                                    output[idx].namedVariables = model.count();
                                case MEnum(_, _, arguments):
                                    output[idx].indexedVariables = arguments.count();
                                case MAnon(model):
                                    output[idx].namedVariables = model.count();
                                case MClass(type, model):
                                    output[idx].namedVariables = model.count();
                                case _:
                            }
                        }
                        
                        Result.Success(output);
                    case MAnon(model):
                        Result.Success([]);
                    case MClass(type, model):
                        Result.Success([]);
                }
            case store:
                final output = new Array<Variable>();
                final names  = store.getLocals();
                final start  = if (_start == null) 0 else _start;
                final count  = if (_count == null) names.length else _count;

                if (start > names.length || start + count > names.length)
                {
                    return Result.Error(new Exception('request out of range of child count'));
                }

                for (idx => name in names.slice(start, start + count))
                {
                    switch store.getLocal(name)
                    {
                        case Success(model):
                            output[idx] = {
                                name  : name,
                                type  : dataType(model),
                                value : dataValue(model),
                                variablesReference: addModel(model)
                            };

                            switch model
                            {
                                case MArray(model):
                                    output[idx].indexedVariables = model.length();
                                case MMap(model):
                                    output[idx].namedVariables = model.count();
                                case MEnum(_, _, arguments):
                                    output[idx].indexedVariables = arguments.count();
                                case MAnon(model):
                                    output[idx].namedVariables = model.count();
                                case MClass(type, model):
                                    output[idx].namedVariables = model.count();
                                case _:
                            }
                        case Error(exn):
                            continue;
                    }
                }

                Result.Success(output);
        }
    }

    public function addModel(_model : ModelData)
    {
        return switch _model
        {
            case MNull, MInt(_), MFloat(_), MBool(_), MString(_), MUnknown(_):
                0;
            case MDynamic(inner):
                addModel(inner);
            case MArray(_), MMap(_), MEnum(_, _, _), MAnon(_), MClass(_, _):
                final id = index++;

                models[id] = _model;
        
                id;
        }
    }

    static function dataValue(_data : ModelData)
    {
        return switch _data
        {
            case MNull:
                'null';
            case MInt(v):
                Std.string(v);
            case MFloat(v):
                Std.string(v);
            case MBool(v):
                Std.string(v);
            case MString(s):
                s;
            case MArray(model):
                '[ ${ model.length() } items ]';
            case MMap(model):
                '[ ${ model.count() } keys ]';
            case MEnum(type, constructor, arguments):
                '${ printType(type) }.$constructor';
            case MDynamic(inner):
                dataValue(inner);
            case MAnon(fields):
                '{}';
            case MClass(type, fields):
                printType(type);
            case MUnknown(type):
                'unknown';
        }
    }

    static function dataType(_data : ModelData)
    {
        return switch _data
        {
            case MNull:
                'Null';
            case MInt(_):
                'Int';
            case MFloat(_):
                'Float';
            case MBool(_):
                'Bool';
            case MString(_):
                'String';
            case MArray(_):
                'Array<?>';
            case MMap(_):
                'Map<?, ?>';
            case MEnum(type, _, _):
                printType(type);
            case MDynamic(inner):
                'Dynamic';
            case MAnon(fields):
                '{}';
            case MClass(type, _):
                printType(type);
            case MUnknown(type):
                type;
        }
    }

    static function printType(_type : GeneratedType)
    {
        return if (_type.module != _type.name)
        {
            '${ _type.pack.join('.') }.${ _type.module }.${ _type.name }';
        }
        else
        {
            '${ _type.pack.join('.') }.${ _type.name }';
        }
    }
}