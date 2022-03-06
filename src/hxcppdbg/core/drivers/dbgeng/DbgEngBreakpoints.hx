package hxcppdbg.core.drivers.dbgeng;

import hxcppdbg.core.ds.Result;
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
		return switch objects.createBreakpoint(_file, _line)
        {
            case Success(v):
                v;
            case Error(_):
                null;
        }
	}

	public function remove(_id : Int) : Bool
    {
		throw new haxe.exceptions.NotImplementedException();
	}
}