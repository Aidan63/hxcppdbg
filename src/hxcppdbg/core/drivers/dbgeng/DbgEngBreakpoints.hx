package hxcppdbg.core.drivers.dbgeng;

import hxcppdbg.core.drivers.dbgeng.native.DbgEngObjects;

class DbgEngBreakpoints implements IBreakpoints
{
    final objects : DbgEngObjects;

    public function new(_objects)
    {
        objects = _objects;
    }
    
	public function create(_file : String, _line : Int)
    {
		return objects.createBreakpoint(_file, _line);
	}

	public function remove(_id : Int) : Bool
    {
		throw new haxe.exceptions.NotImplementedException();
	}
}