package hxcppdbg.core.drivers.lldb;

import haxe.Exception;
import haxe.exceptions.NotImplementedException;
import hxcppdbg.core.ds.Result;
import hxcppdbg.core.model.Model;
import hxcppdbg.core.locals.NativeLocal;
import hxcppdbg.core.drivers.lldb.native.LLDBProcess;

class LLDBLocals implements ILocals
{
    public function new()
    {
        //
    }

	public function getVariables(_thread : Int, _frame : Int, _callback : Result<Array<Model>, Exception>->Void) : Void
    {
		throw new NotImplementedException();
	}

	public function getArguments(_thread : Int, _frame : Int, _callback : Result<Array<Model>, Exception>->Void) : Void
    {
        throw new NotImplementedException();
    }
}