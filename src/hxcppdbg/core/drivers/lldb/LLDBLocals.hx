package hxcppdbg.core.drivers.lldb;

import hxcppdbg.core.locals.NativeLocal;
import hxcppdbg.core.drivers.lldb.native.LLDBProcess;

class LLDBLocals implements ILocals
{
    final process : LLDBProcess;

    public function new(_process)
    {
        process = _process;
    }

	public function getVariables(_thread : Int, _frame : Int)
    {
		return process.getStackVariables(_thread, _frame).map(variableToNativeLocal);
	}

	public function getArguments(_thread:Int, _frame:Int)
    {
        //
    }

    function variableToNativeLocal(_input : Variable)
    {
        return new NativeLocal(_input.name, _input.type, _input.value);
    }
}