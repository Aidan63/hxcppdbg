package hxcppdbg.core.drivers.dbgeng;

import hxcppdbg.core.drivers.dbgeng.native.DbgEngObjects;

using hxcppdbg.core.utils.ResultUtils;
using hxcppdbg.core.utils.OptionUtils;

class DbgEngBreakpoints implements IBreakpoints
{
    final objects : DbgEngObjects;

    public function new(_objects)
    {
        objects = _objects;
    }
    
	public function create(_file : String, _line : Int)
    {
		return objects.createBreakpoint(_file, _line).asExceptionResult();
	}

	public function remove(_id : Int)
    {
		return objects.removeBreakpoint(_id).asExceptionOption();
	}
}