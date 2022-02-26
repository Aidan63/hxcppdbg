package hxcppdbg.core.drivers;

interface IBreakpoints
{
    public function create(_file : String, _line : Int) : Null<Int>;

    public function remove(_id : Int) : Bool;
}