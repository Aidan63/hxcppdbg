package hxcppdbg.core.drivers.lldb;

import hxcppdbg.core.drivers.lldb.native.LLDBProcess;

using StringTools;

class LLDBStack implements IStack
{
    final process : LLDBProcess;

    public function new(_process)
    {
        process = _process;
    }

	public function getCallStack(_thread)
    {
		return process.getStackFrames(_thread);
	}

    public function getFrame(_thread:Int, _index:Int)
    {
		return process.getStackFrame(_thread, _index);
	}
}