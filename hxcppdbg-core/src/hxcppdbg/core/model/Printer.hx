package hxcppdbg.core.model;

import haxe.Int64;
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
            case MClass(_, _):
                '{ }';
            case MNative(native):
                switch native
                {
                    case NPointer(address, _):
                        addressToHex(address);
                    case NType(_, _):
                        '{ }';
                    case NArray(_, model):
                        switch model.count()
                        {
                            case Success(count):
                                '[ $count items ]';
                            case Error(exn):
                                exn.message;
                        }
                    case NUnknown(_):
                        'Unknown';
                }
        }
    }
    
    public static function printType(_data : ModelData)
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
            case MEnum(_, constructor, _):
                '${ printGeneratedType }.$constructor';
            case MAnon(_):
                '{}';
            case MClass(type, _):
                printGeneratedType(type);
            case MNative(native):
                switch native
                {
                    case NPointer(_, dereferenced):
                        '${ printType(dereferenced) }*';
                    case NArray(type, model):
                        switch model.count()
                        {
                            case Success(count):
                                '$type[$count]';
                            case Error(exn):
                                exn.message;
                        }
                    case NType(type, _), NUnknown(type):
                        type;
                }
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

	private static function addressToHex(address : Int64)
    {
        final builder  = [];
        final hexChars = '0123456789abcdef';

        do
        {
            builder.insert(0, hexChars.charAt(Int64.toInt(address & 15)));
            address >>>= 4;
        }
        while (address > 0);

        while (builder.length < 16)
        {
            builder.insert(0, 'f');
        }

        return '0x${ builder.join('') }';
	}
}