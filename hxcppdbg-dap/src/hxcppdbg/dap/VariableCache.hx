package hxcppdbg.dap;

import hxcppdbg.core.sourcemap.Sourcemap.GeneratedType;
import haxe.ds.Option;
import hxcppdbg.core.model.Model;
import hxcppdbg.core.model.ModelData;
import hxcppdbg.core.locals.LocalVariable;
import hxcppdbg.dap.protocol.Variable;

using Lambda;

class VariableCache
{
    final cache : Map<Int, Array<Model>>;

    var index : Int;

    public function new()
    {
        cache = [];
        index = 1;
    }

    public function insert(_locals : Array<LocalVariable>)
    {
        return addModels(_locals.map(localToModel));
    }

    public function get(_id : Int) : Option<Array<Variable>>
    {
        return switch cache[_id]
        {
            case null:
                Option.None;
            case models:
                Option.Some(models.map(modelToVariable));
        }
    }

    function process(_data : ModelData)
    {
        return switch _data
        {
            case
                MNull,
                MInt(_),
                MFloat(_),
                MBool(_),
                MString(_),
                MArray([]),
                MMap([]),
                MEnum(_, _, []),
                MUnknown(_):
                Option.None;
            case MArray(items):
                Option.Some(addModelDatas(items));
            case MMap(items):
                Option.Some(addModels(items));
            case MEnum(_, _, arguments):
                Option.Some(addModelDatas(arguments));
            case MDynamic(inner):
                process(inner);
            case MAnon(fields):
                Option.Some(addModels(fields));
            case MClass(_, fields):
                Option.Some(addModels(fields));
        }
    }

    function addModels(_models : Array<Model>)
    {
        final id = index++;

        cache[id] = _models;

        return id;
    }

    function addModelDatas(_data : Array<ModelData>)
    {
        return addModels(_data.mapi((i, d) -> new Model(MInt(i), d)));
    }

    static function localToModel(_local : LocalVariable)
    {
        return switch _local
        {
            case Native(_model):
                _model;
            case Haxe(_model):
                _model;
        }
    }

    function modelToVariable(_model : Model) : Variable
    {
        final children = switch process(_model.data)
        {
            case Some(id):
                id;
            case None:
                0;
        }

        return {
            name               : keyAsName(_model.key),
            variablesReference : children,
            value              : dataAsValue(_model.data),
            type               : dataType(_model.data)
        }
    }

    static function keyAsName(_data : ModelData)
    {
        return switch _data
        {
            case MInt(v):
                Std.string(v);
            case MFloat(v):
                Std.string(v);
            case MBool(v):
                Std.string(v);
            case MString(s):
                s;
            case _:
                'invalid_key';
        }
    }

    static function dataAsValue(_data : ModelData)
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
            case MArray(_), MMap(_):
                '[]';
            case MEnum(type, constructor, arguments):
                '${ printType(type) }.$constructor';
            case MDynamic(inner):
                dataAsValue(inner);
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