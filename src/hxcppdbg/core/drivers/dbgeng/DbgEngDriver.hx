package hxcppdbg.core.drivers.dbgeng;

import hxcppdbg.core.drivers.dbgeng.native.DbgEngObjects;

class DbgEngDriver extends Driver
{
	final objects : DbgEngObjects;

	public function new(_file, _onBreakpointCb)
	{
		objects     = DbgEngObjects.createFromFile(_file, _onBreakpointCb);
		breakpoints = new DbgEngBreakpoints(objects);
	}

	public function start()
	{
		objects.start();
	}

	public function stop() {}

	public function pause() {}

	public function resume() {}
}