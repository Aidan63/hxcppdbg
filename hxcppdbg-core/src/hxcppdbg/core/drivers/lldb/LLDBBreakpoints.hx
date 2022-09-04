package hxcppdbg.core.drivers.lldb;

import haxe.exceptions.NotImplementedException;
import haxe.Exception;
import haxe.ds.Option;
import hxcppdbg.core.ds.Result;

class LLDBBreakpoints implements IBreakpoints
{
    public function new()
    {
        //
    }

	public function create(_file : String, _line : Int, _result : Result<Int, Exception>->Void) : Void
    {
		throw new NotImplementedException();
	}

	public function remove(_id : Int, _result : Option<Exception>->Void) : Void
    {
        throw new NotImplementedException();
    }
}