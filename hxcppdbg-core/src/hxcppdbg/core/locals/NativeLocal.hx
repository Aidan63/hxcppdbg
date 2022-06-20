package hxcppdbg.core.locals;

class NativeLocal
{
    public final name : String;

    public final type : String;

    public final value : String;

    public function new(_name, _type, _value)
    {
        name  = _name;
        type  = _type;
        value = _value;
    }
}