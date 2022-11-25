package hxcppdbg.core.model;

import hxcppdbg.core.sourcemap.Sourcemap.GeneratedType;

class Printer
{
    public static function printModelData(_data : ModelData)
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
                switch items.count()
                {
                    case Success(v):
                        '[ $v items ]';
                    case Error(exn):
                        exn.message;
                }
            case MMap(items):
                switch items.count()
                {
                    case Success(v):
                        '[ $v keys ]';
                    case Error(exn):
                        exn.message;
                }
            case MEnum(_, constructor, arguments):
                switch arguments.count()
                {
                    case Success(v):
                        '$constructor( $v args )';
                    case Error(exn):
                        exn.message;
                }
            case MAnon(fields):
                switch fields.count()
                {
                    case Success(v):
                        '{ $v fields }';
                    case Error(exn):
                        exn.message;
                }
            case MClass(_, fields):
                '{ }';
            case MUnknown(type):
                'unknown ($type)';
        }
    }
    
    public static function printType(_data : ModelData)
    {
        return switch _data
        {
            case MNull:
                '?';
            case MInt(i):
                'Int';
            case MFloat(f):
                'Float';
            case MBool(b):
                'Bool';
            case MString(s):
                'String';
            case MArray(items):
                'Array<?>';
            case MMap(items):
                'Map<?, ?>';
            case MEnum(type, constructor, arguments):
                '${ printGeneratedType }.$constructor';
            case MAnon(fields):
                '{}';
            case MClass(type, _):
                printGeneratedType(type);
            case MUnknown(type):
                type;
        }
    }

    private static function printGeneratedType(_type : GeneratedType)
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
}