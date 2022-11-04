package hxcppdbg.dap;

import haxe.Exception;
import hxcppdbg.dap.protocol.data.Variable;
import hxcppdbg.core.ds.Result;
import hxcppdbg.core.model.Keyable;
import hxcppdbg.core.model.ModelData;
import hxcppdbg.core.locals.LocalStore;
import hxcppdbg.core.sourcemap.Sourcemap.GeneratedType;

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
                    case MArray(store), MEnum(_, _, store):
                        switch store.count()
                        {
                            case Success(length):
                                final start  = if (_start == null) 0 else _start;
                                final count  = if (_count == null) length else _count;
                                final output = new Array<Variable>();
        
                                if (start >= length || start + count > length)
                                {
                                    return Result.Error(new Exception('request out of range of child count'));
                                }

                                for (i in start...(start + count))
                                {
                                    switch store.at(i)
                                    {
                                        case Success(model):
                                            output.push({
                                                variablesReference: addModel(model),
                                                name  : Std.string(i),
                                                type  : model.printType(),
                                                value : model.printModelData()
                                            });
                
                                            switch model
                                            {
                                                case MArray(model), MEnum(_, _, model):
                                                    output[output.length - 1].indexedVariables = switch model.count() {
                                                        case Success(v):
                                                            v;
                                                        case Error(_):
                                                            0;
                                                    };
                                                case MMap(model):
                                                    output[output.length - 1].namedVariables = switch model.count()
                                                    {
                                                        case Success(v):
                                                            v;
                                                        case Error(_):
                                                            0;
                                                    }
                                                case MAnon(model), MClass(_, model):
                                                    output[output.length - 1].namedVariables = switch model.count()
                                                    {
                                                        case Success(v):
                                                            v;
                                                        case Error(_):
                                                            0;
                                                    }
                                                case _:
                                                    //
                                            }
                                        case Error(exn):
                                            //
                                    }
                                }
                                
                                Result.Success(output);
                            case Error(exn):
                                Result.Error(exn);
                        }
                    case MMap(store):
                        switch store.count()
                        {
                            case Success(length):
                                final start  = if (_start == null) 0 else _start;
                                final count  = if (_count == null) length else _count;
                                final output = new Array<Variable>();

                                if (start >= length || start + count > length)
                                {
                                    return Result.Error(new Exception('request out of range of child count'));
                                }

                                for (i in start...(start + count))
                                {
                                    switch store.at(i)
                                    {
                                        case Success(model):
                                            output.push({
                                                variablesReference: addModel(model),
                                                name  : Std.string(i),
                                                type  : model.printType(),
                                                value : model.printModelData()
                                            });
                
                                            switch model
                                            {
                                                case MArray(model), MEnum(_, _, model):
                                                    output[output.length - 1].indexedVariables = switch model.count() {
                                                        case Success(v):
                                                            v;
                                                        case Error(_):
                                                            0;
                                                    };
                                                case MMap(model):
                                                    output[output.length - 1].namedVariables = switch model.count()
                                                    {
                                                        case Success(v):
                                                            v;
                                                        case Error(_):
                                                            0;
                                                    }
                                                case MAnon(model), MClass(_, model):
                                                    output[output.length - 1].namedVariables = switch model.count()
                                                    {
                                                        case Success(v):
                                                            v;
                                                        case Error(_):
                                                            0;
                                                    }
                                                case _:
                                                    //
                                            }
                                        case Error(exn):
                                            //
                                    }
                                }

                                Result.Success(output);
                            case Error(exn):
                                Result.Error(exn);
                        }
                    case MAnon(store), MClass(_, store):
                        switch store.count()
                        {
                            case Success(length):
                                final start  = if (_start == null) 0 else _start;
                                final count  = if (_count == null) length else _count;
                                final output = new Array<Variable>();

                                if (start >= length || start + count > length)
                                {
                                    return Result.Error(new Exception('request out of range of child count'));
                                }

                                for (i in start...(start + count))
                                {
                                    switch store.at(i)
                                    {
                                        case Success(model):
                                            output.push({
                                                variablesReference: addModel(model),
                                                name  : Std.string(i),
                                                type  : model.printType(),
                                                value : model.printModelData()
                                            });
                
                                            switch model
                                            {
                                                case MArray(model), MEnum(_, _, model):
                                                    output[output.length - 1].indexedVariables = switch model.count() {
                                                        case Success(v):
                                                            v;
                                                        case Error(_):
                                                            0;
                                                    };
                                                case MMap(model):
                                                    output[output.length - 1].namedVariables = switch model.count()
                                                    {
                                                        case Success(v):
                                                            v;
                                                        case Error(_):
                                                            0;
                                                    }
                                                case MAnon(model), MClass(_, model):
                                                    output[output.length - 1].namedVariables = switch model.count()
                                                    {
                                                        case Success(v):
                                                            v;
                                                        case Error(_):
                                                            0;
                                                    }
                                                case _:
                                                    //
                                            }
                                        case Error(exn):
                                            //
                                    }
                                }

                                Result.Success(output);
                            case Error(exn):
                                Result.Error(exn);
                        }
                }
            case store:
                switch store.count()
                {
                    case Success(length):
                        final output = new Array<Variable>();
                        final start  = if (_start == null) 0 else _start;
                        final count  = if (_count == null) length else _count;

                        if (start > length || start + count > length)
                        {
                            return Result.Error(new Exception('request out of range of child count'));
                        }

                        for (i in start...(start + count))
                        {
                            switch store.at(i)
                            {
                                case Success(model):
                                    output.push({
                                        variablesReference: addModel(model),
                                        name  : Std.string(i),
                                        type  : model.printType(),
                                        value : model.printModelData()
                                    });
        
                                    switch model
                                    {
                                        case MArray(model), MEnum(_, _, model):
                                            output[output.length - 1].indexedVariables = switch model.count() {
                                                case Success(v):
                                                    v;
                                                case Error(_):
                                                    0;
                                            };
                                        case MMap(model):
                                            output[output.length - 1].namedVariables = switch model.count()
                                            {
                                                case Success(v):
                                                    v;
                                                case Error(_):
                                                    0;
                                            }
                                        case MAnon(model), MClass(_, model):
                                            output[output.length - 1].namedVariables = switch model.count()
                                            {
                                                case Success(v):
                                                    v;
                                                case Error(_):
                                                    0;
                                            }
                                        case _:
                                            //
                                    }
                                case Error(exn):
                                    //
                            }
                        }

                        Result.Success(output);
                    case Error(exn):
                        Result.Error(exn);
                }
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