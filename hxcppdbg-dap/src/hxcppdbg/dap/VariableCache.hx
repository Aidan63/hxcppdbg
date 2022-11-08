package hxcppdbg.dap;

import haxe.Exception;
import hxcppdbg.dap.protocol.data.Variable;
import hxcppdbg.core.ds.Result;
import hxcppdbg.core.model.Keyable;
import hxcppdbg.core.model.ModelData;
import hxcppdbg.core.model.KeyValuePair;
import hxcppdbg.core.locals.LocalStore;
import hxcppdbg.core.sourcemap.Sourcemap.GeneratedType;

using Lambda;

private enum abstract ReferenceType(Int) from Int to Int
{
    var Scope;
    var Model;
    var KeyValue;
}

private abstract VariableReference(Int) from Int to Int
{
    public var type (get, never) : ReferenceType;

    function get_type()
    {
        return (this >> 24) & 0xff;
    }

    public var number (get, never) : Int;

    function get_number()
    {
        return this & 0xffffff;
    }

    public function new(_type : ReferenceType, _number : Int)
    {
        this = ((_type & 0xff) << 24) | (_number & 0xffffff);
    }
}

class VariableCache
{
    final scopes : Map<Int, LocalStore>;

    final models : Map<Int, ModelData>;

    final mapRoots : Map<Int, KeyValuePair>;

    var index : Int;

    public function new()
    {
        scopes   = [];
        models   = [];
        mapRoots = [];
        index    = 1;
    }

    public function clear()
    {
        scopes.clear();
        models.clear();
        mapRoots.clear();
        index = 1;
    }

    public function createScope(_locals : LocalStore)
    {
        final id = index++;

        scopes[id] = _locals;

        return new VariableReference(ReferenceType.Scope, id);
    }

    public function fetch(_id : VariableReference, _start : Null<Int>, _count : Null<Int>) : Result<Array<Variable>, Exception>
    {
        return switch _id.type
        {
            case Scope:
                switch scopes[_id.number]
                {
                    case null:
                        Result.Error(new Exception('No scope with ID ${ _id.number }'));
                    case store:
                        switch store.count()
                        {
                            case Success(length):
                                final output = new Array<Variable>();
                                final start  = if (_start == null) 0 else _start;
                                final count  = if (_count == null) length else _count;
        
                                if (start > length || start + count > length)
                                {
                                    return Result.Error(new Exception('Request out of range'));
                                }
                                
                                for (i in start...(start + count))
                                {
                                    switch store.at(i)
                                    {
                                        case Success(field):
                                            output.push({
                                                variablesReference: addModel(field.data),
                                                name  : field.name,
                                                type  : field.data.printType(),
                                                value : field.data.printModelData()
                                            });
                
                                            switch field.data
                                            {
                                                case MArray(model), MEnum(_, _, model):
                                                    output[output.length - 1].indexedVariables = switch model.count() {
                                                        case Success(v):
                                                            v;
                                                        case Error(_):
                                                            0;
                                                    };
                                                case MMap(model):
                                                    output[output.length - 1].indexedVariables = switch model.count() {
                                                        case Success(v):
                                                            v;
                                                        case Error(_):
                                                            0;
                                                    };
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
                                            // return Result.Error(new Exception('Failed to get variable $i', exn));
                                    }
                                }
                                
                                Result.Success(output);
                            case Error(exn):
                                Result.Error(new Exception('Failed to get number of variables in the scope', exn));
                        }
                }
            case Model:
                switch models[_id.number]
                {
                    case null:
                        Result.Error(new Exception('No model with ID ${ _id.number }'));
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
                                                    output[output.length - 1].indexedVariables = switch model.count() {
                                                        case Success(v):
                                                            v;
                                                        case Error(_):
                                                            0;
                                                    };
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
                                            // return Result.Error(new Exception('Failed to get child at index $i', exn));
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
                                                variablesReference : addKeyValuePair(model),
                                                name               : Std.string(i),
                                                value              : 'key value pair',
                                                namedVariables     : 2
                                            });
                                        case Error(exn):
                                            // return Result.Error(new Exception('Failed to get child at index $i', exn));
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
                                        case Success(field):
                                            output.push({
                                                variablesReference: addModel(field.data),
                                                name  : field.name,
                                                type  : field.data.printType(),
                                                value : field.data.printModelData()
                                            });
                
                                            switch field.data
                                            {
                                                case MArray(model), MEnum(_, _, model):
                                                    output[output.length - 1].indexedVariables = switch model.count() {
                                                        case Success(v):
                                                            v;
                                                        case Error(_):
                                                            0;
                                                    };
                                                case MMap(model):
                                                    output[output.length - 1].indexedVariables = switch model.count() {
                                                        case Success(v):
                                                            v;
                                                        case Error(_):
                                                            0;
                                                    };
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
                                            // return Result.Error(new Exception('Failed to get child at index $i', exn));
                                    }
                                }

                                Result.Success(output);
                            case Error(exn):
                                Result.Error(exn);
                        }
                }
            case KeyValue:
                switch mapRoots[_id.number]
                {
                    case null:
                        Result.Error(new Exception('Failed to find model in storage'));
                    case root:
                        Result.Success([
                            {
                                variablesReference: addModel(root.key),
                                name  : 'Key',
                                type  : root.key.printType(),
                                value : root.key.printModelData()
                            },
                            {
                                variablesReference: addModel(root.value),
                                name  : 'Value',
                                type  : root.value.printType(),
                                value : root.value.printModelData()
                            }
                        ]);
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
        
                new VariableReference(ReferenceType.Model, id);
        }
    }

    function addKeyValuePair(_pair : KeyValuePair)
    {
        final id = index++;

        mapRoots[id] = _pair;

        return new VariableReference(ReferenceType.KeyValue, id);
    }
}