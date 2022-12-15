package hxcppdbg.core.model;

import hxcppdbg.core.sourcemap.Sourcemap.GeneratedType;

@:cppInclude("sstream")
@:cppInclude("iomanip")
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
                    case NType(_, model):
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

	private static function addressToHex(n : cpp.UInt64)
    {
		untyped __cpp__("
        std::stringstream stream;

        stream
            << \"0x\"
            /*<< std::setFill('0')
            << std::setw(sizeof(uint64_t) * 2)*/
            << std::hex
            << {0};
            
        auto str = stream.str().c_str();", n);

		return new String(untyped str);
	}
}