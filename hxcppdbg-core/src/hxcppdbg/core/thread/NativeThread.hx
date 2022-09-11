package hxcppdbg.core.thread;

class NativeThread
{
    public final index : Int;

    public final name : String;

    public function new(_index, _name)
    {
        index = _index;
        name  = _name;
    }
}