package hxcppdbg.core.drivers.dbgeng;

import hxcppdbg.core.drivers.dbgeng.native.DbgEngObjects;

class DbgEngDriver extends Driver
{
	final objects : DbgEngObjects;

	public function new(_file)
	{
		objects     = DbgEngObjects.createFromFile(_file);
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