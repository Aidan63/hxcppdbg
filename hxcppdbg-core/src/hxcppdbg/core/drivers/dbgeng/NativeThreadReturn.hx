package hxcppdbg.core.drivers.dbgeng;

class NativeThreadReturn
{
    public final sysId : Int;

    public final name : String;

    public function new(_sysId, _name)
    {
        sysId = _sysId;
        name  = _name;
    }
}