package hxcppdbg.core.model;

function printModel(_model : Model)
{
    trace(_model);

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
            s;
        case MArray(items):
            '[ ${ items.map(printModelData).join(', ') } ]';
        case MMap(items):
            '[ ${ items.map(printModel).join(', ') } ]';
        case MEnum(name, arguments):
            '$name(${ arguments.map(printModelData).join(', ') })';
        case MDynamic(inner):
            printModelData(inner);
        case MAnon(fields):
            '{ ${ fields.map(printModel).join(', ') } }';
        case MUnknown(type):
            'unknown ($type)';
    }
}