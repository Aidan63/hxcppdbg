package hxcppdbg.core.drivers;

import haxe.Exception;
import haxe.ds.Option;
import hxcppdbg.core.ds.Result;

interface IBreakpoints
{
    public function create(_file : String, _line : Int, _result : Result<Int, Exception>->Void) : Void;

    public function remove(_id : Int, _result : Option<Exception>->Void) : Void;
}