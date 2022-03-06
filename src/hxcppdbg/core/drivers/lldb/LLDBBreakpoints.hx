package hxcppdbg.core.drivers.lldb;

import hxcppdbg.core.drivers.lldb.native.LLDBObjects;

class LLDBBreakpoints implements IBreakpoints
{
    final object : LLDBObjects;

    public function new(_object)
    {
        object = _object;
    }

	public function create(_file : String, _line : Int)
    {
		return object.setBreakpoint(_file, _line);
	}

	public function remove(_id : Int)
    {
        return object.removeBreakpoint(_id);
    }
}