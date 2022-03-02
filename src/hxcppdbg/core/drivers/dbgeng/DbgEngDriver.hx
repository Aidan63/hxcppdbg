package hxcppdbg.core.drivers.dbgeng;

import haxe.exceptions.NotImplementedException;
import hxcppdbg.core.drivers.dbgeng.native.DbgEngObjects;

class DbgEngDriver extends Driver
{
	private static inline final GO = 1;

	private static inline final STEP_OVER = 4;

	private static inline final STEP_INTO = 5;

	final objects : DbgEngObjects;

	public function new(_file, _onBreakpointCb)
	{
		objects     = DbgEngObjects.createFromFile(_file, _onBreakpointCb);
		breakpoints = new DbgEngBreakpoints(objects);
		stack       = new DbgEngStack(objects);
	}

	public function start()
	{
		objects.start(GO);
	}

	public function resume()
	{
		objects.start(GO);
	}

	public function pause()
	{
		//
	}

	public function stop()
	{
		//
	}

	public function step(_thread : Int, _type : StepType)
	{
		switch _type
		{
			case In:
				objects.step(_thread, STEP_INTO);
			case Over:
				objects.step(_thread, STEP_OVER);
			case Out:
				throw new NotImplementedException();
		}
	}
}