package hxcppdbg.core.drivers.lldb;

import hxcppdbg.core.drivers.lldb.native.LLDBProcess;
import haxe.Exception;
import hxcppdbg.core.ds.Result;
import hxcppdbg.core.stack.NativeFrame;
import haxe.exceptions.NotImplementedException;

class LLDBStack implements IStack
{
    public function new()
    {
        //
    }

	public function getCallStack(_thread : Int, _result : Result<Array<NativeFrame>, Exception>->Void) : Void
    {
		throw new NotImplementedException();
	}

    public function getFrame(_thread : Int, _index : Int, _result : Result<NativeFrame, Exception>->Void) : Void
    {
		throw new NotImplementedException();
	}
}