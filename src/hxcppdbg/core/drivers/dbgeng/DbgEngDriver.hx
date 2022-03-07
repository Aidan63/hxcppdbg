package hxcppdbg.core.drivers.dbgeng;

import haxe.Exception;
import haxe.ds.Option;
import haxe.exceptions.NotImplementedException;
import hxcppdbg.core.drivers.dbgeng.native.DbgEngObjects;

using hxcppdbg.core.utils.ResultUtils;
using hxcppdbg.core.utils.OptionUtils;

class DbgEngDriver extends Driver
{
	private static inline final GO = 1;

	private static inline final STEP_OVER = 4;

	private static inline final STEP_INTO = 5;

	final objects : DbgEngObjects;

	public function new(_file, _onBreakpointCb)
	{
		objects     = DbgEngObjects.createFromFile(_file, _onBreakpointCb).resultOrThrow();
		breakpoints = new DbgEngBreakpoints(objects);
		stack       = new DbgEngStack(objects);
		locals      = new DbgEngLocals(objects);
	}

	public function start()
	{
		return objects.start(GO).asExceptionOption();
	}

	public function resume()
	{
		return objects.start(GO).asExceptionOption();
	}

	public function pause() : Option<Exception>
	{
		throw new NotImplementedException();
	}

	public function stop() : Option<Exception>
	{
		throw new NotImplementedException();
	}

	public function step(_thread : Int, _type : StepType)
	{
		return switch _type
		{
			case In:
				return objects.step(_thread, STEP_INTO).asExceptionOption();
			case Over:
				return objects.step(_thread, STEP_OVER).asExceptionOption();
			case Out:
				throw new NotImplementedException();
				// Dbgeng doesn't seem to have a build in step out? Are we suppose to inspect the return
				// address and continue to that somehow?
				// In any case get the current stack trace and keep stepping over until we end up back at the previous frame.
				// This could take a very long time if you step out in the middle of a long function...
				// final stack = objects.getCallStack(_thread);

				// switch stack.length
				// {
				// 	case 0, 1:
				// 		return;
				// 	case _:
				// 		final previous = stack[1];

				// 		while (true)
				// 		{
				// 			objects.step(_thread, STEP_OVER);

				// 			final top = objects.getFrame(_thread, 0);

				// 			if (top.address == previous.address)
				// 			{
				// 				return;
				// 			}
				// 		}
				// }
		}
	}
}