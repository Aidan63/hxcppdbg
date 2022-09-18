package hxcppdbg.core.drivers;

import haxe.Int64;
import haxe.Exception;
import haxe.ds.Option;
import hxcppdbg.core.ds.Result;

interface IBreakpoints
{
    public function create(_file : String, _line : Int, _result : Result<Int64, Exception>->Void) : Void;

    public function remove(_id : Int64, _result : Option<Exception>->Void) : Void;
}