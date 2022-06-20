package hxcppdbg.core.drivers.dbgeng;

import tink.cli.Result;
import hxcppdbg.core.ds.Result;
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

	public function new(_file, _enums, _classes)
	{
		objects     = DbgEngObjects.createFromFile(_file, _enums, _classes).resultOrThrow();
		breakpoints = new DbgEngBreakpoints(objects);
		stack       = new DbgEngStack(objects);
		locals      = new DbgEngLocals(objects);
	}

	public function start()
	{
		return objects.start(GO).asExceptionResult();
	}

	public function resume()
	{
		return objects.start(GO).asExceptionResult();
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
				return objects.step(_thread, STEP_INTO).asExceptionResult();
			case Over:
				return objects.step(_thread, STEP_OVER).asExceptionResult();
			case Out:
				// Dbgeng doesn't seem to have a build in step out? Are we suppose to inspect the return
				// address and continue to that somehow?
				// In any case get the current stack trace and keep stepping over until we end up back at the previous frame.
				// This could take a very long time if you step out in the middle of a long function...
				switch objects.getCallStack(_thread)
				{
					case Success(stack):
						switch stack.length
						{
							case 0, 1:
								Result.Error(new Exception('No frame to step out into'));
							case _:
								final previous = stack[1];
		
								while (true)
								{
									switch objects.step(_thread, STEP_OVER)
									{
										case Success(Natural):
											switch objects.getFrame(_thread, 0)
											{
												case Success(top):
													if (top.address == previous.address)
													{
														return Result.Success(StopReason.Natural);
													}
												case Error(e):
													return Result.Error((e : Exception));
											}
										case Success(other):
											return Success(other);
										case Error(e):
											return Result.Error((e : Exception));
									}
								}

								return Result.Success(StopReason.Natural);
						}
					case Error(e):
						Result.Error((e : Exception));
				}
		}
	}
}