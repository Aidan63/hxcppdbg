package hxcppdbg.core.drivers.lldb;

import hxcppdbg.core.ds.Result;
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
		return process.getStackVariables(_thread, _frame);
	}

	public function getArguments(_thread:Int, _frame:Int)
    {
        process.getStackVariables(_thread, _frame);

        return Result.Success([]);
    }
}