package hxcppdbg.core.drivers;

import haxe.Exception;
import haxe.ds.Option;
import hxcppdbg.core.ds.Result;

interface IBreakpoints
{
    public function create(_file : String, _line : Int) : Result<Int, Exception>;

    public function remove(_id : Int) : Option<Exception>;
}