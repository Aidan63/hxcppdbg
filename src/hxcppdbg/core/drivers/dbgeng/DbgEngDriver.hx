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
		locals      = new DbgEngLocals(objects);
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
				// Dbgeng doesn't seem to have a build in step out? Are we suppose to inspect the return
				// address and continue to that somehow?
				// In any case get the current stack trace and keep stepping over until we end up back at the previous frame.
				// This could take a very long time if you step out in the middle of a long function...
				final stack = objects.getCallStack(_thread);

				switch stack.length
				{
					case 0, 1:
						return;
					case _:
						final previous = stack[1];

						while (true)
						{
							objects.step(_thread, STEP_OVER);

							final top = objects.getFrame(_thread, 0);

							if (top.address == previous.address)
							{
								return;
							}
						}
				}
				throw new NotImplementedException();
		}
	}
}