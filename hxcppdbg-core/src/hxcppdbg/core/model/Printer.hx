package hxcppdbg.core.model;

import hxcppdbg.core.model.ModelData.MapType;
import hxcppdbg.core.sourcemap.Sourcemap.GeneratedType;

function printModel(_model : Model)
{
    return '${ printModelData(_model.key) } : ${ printModelData(_model.data) }';
}

function printModelData(_data : ModelData)
{
    return switch _data
    {
        case MNull:
            'null';
        case MInt(i):
            Std.string(i);
        case MFloat(f):
            Std.string(f);
        case MBool(b):
            Std.string(b);
        case MString(s):
            '"$s"';
        case MArray(items):
            '[ ${ items.length() } items ]';
        case MMap(type):
            switch type
            {
                case KInt(model):
                    '[ ${ model.count() } keys ]';
                case KString(model):
                    '[ ${ model.count() } keys ]';
            }
        case MEnum(_, constructor, arguments):
            '$constructor(${ arguments.map(printModelData).join(', ') })';
        case MDynamic(inner):
            printModelData(inner);
        case MAnon(fields):
            '{ ${ fields.map(printModel).join(', ') } }';
        case MClass(_, fields):
            '{ ${ fields.map(printModel).join(', ') } }';
        case MUnknown(type):
            'unknown ($type)';
    }
}

function printType(_type : GeneratedType)
{
    return if (_type.module == _type.name)
    {
        if (_type.pack.length == 0)
        {
            _type.name;
        }
        else
        {
            '${ _type.pack.join('.') }.${ _type.name }';
        }
    }
    else
    {
        if (_type.pack.length == 0)
        {
            '${ _type.module }.${ _type.name }';
        }
        else
        {
            '${ _type.pack.join('.') }.${ _type.module }.${ _type.name }';
        }
    }
}