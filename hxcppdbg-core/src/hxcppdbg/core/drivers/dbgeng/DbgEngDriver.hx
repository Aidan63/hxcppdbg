package hxcppdbg.core.drivers.dbgeng;

import sys.thread.Thread;
import sys.thread.EventLoop.EventHandler;
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

	final cbThread : Thread;

	final dbgThread : Thread;

	var heartbeat : Null<EventHandler>;

	var waitLoop : Null<EventHandler>;

	public function new(_file, _enums, _classes)
	{
		objects     = DbgEngObjects.alloc();
		breakpoints = new DbgEngBreakpoints(objects);
		stack       = new DbgEngStack(objects);
		locals      = new DbgEngLocals(objects);

		cbThread    = Thread.current();
		dbgThread   = Thread.createWithEventLoop(() -> {
			switch objects.createFromFile(_file, _enums, _classes)
			{
				case Some(v):
					throw v;
				case None:
					heartbeat = Thread.current().events.repeat(noop, 1000);
			};
		});
	}

	public function start(_result : Option<Exception>->Void)
	{
		dbgThread.events.run(() -> {
			waitLoop = dbgThread.events.repeat(waitForEvent, 1);

			final r = objects.go();

			cbThread.events.run(() -> _result(r.asExceptionOption()));
		});
	}

	public function resume(_result : Option<Exception>->Void)
	{
		start(_result);
	}

	public function pause(_result : Option<Exception>->Void)
	{
		dbgThread.events.run(() -> {
			if (waitLoop != null)
			{
				dbgThread.events.cancel(waitLoop);
	
				waitLoop = null;
			}

			// defer our pause until the next event loop iteration.
			// Otherwise the wait loop might be ran once more depending on cancellation order.
			dbgThread.events.run(() -> {
				final r = objects.pause();

				cbThread.events.run(() -> _result(r.asExceptionOption()));
			});
		});
	}

	public function stop(_result : Option<Exception>->Void)
	{
		_result(Option.Some(new NotImplementedException()));
	}

	public function step(_thread : Int, _type : StepType, _result : Option<Exception>->Void)
	{
		_result(Option.Some(new NotImplementedException()));

		// return switch _type
		// {
		// 	case In:
		// 		return objects.step(_thread, STEP_INTO).asExceptionResult();
		// 	case Over:
		// 		return objects.step(_thread, STEP_OVER).asExceptionResult();
		// 	case Out:
		// 		// Dbgeng doesn't seem to have a build in step out? Are we suppose to inspect the return
		// 		// address and continue to that somehow?
		// 		// In any case get the current stack trace and keep stepping over until we end up back at the previous frame.
		// 		// This could take a very long time if you step out in the middle of a long function...
		// 		switch objects.getCallStack(_thread)
		// 		{
		// 			case Success(stack):
		// 				switch stack.length
		// 				{
		// 					case 0, 1:
		// 						Result.Error(new Exception('No frame to step out into'));
		// 					case _:
		// 						final previous = stack[1];
		
		// 						while (true)
		// 						{
		// 							switch objects.step(_thread, STEP_OVER)
		// 							{
		// 								case Success(Natural):
		// 									switch objects.getFrame(_thread, 0)
		// 									{
		// 										case Success(top):
		// 											if (top.address == previous.address)
		// 											{
		// 												return Result.Success(StopReason.Natural);
		// 											}
		// 										case Error(e):
		// 											return Result.Error((e : Exception));
		// 									}
		// 								case Success(other):
		// 									return Success(other);
		// 								case Error(e):
		// 									return Result.Error((e : Exception));
		// 							}
		// 						}

		// 						return Result.Success(StopReason.Natural);
		// 				}
		// 			case Error(e):
		// 				Result.Error((e : Exception));
		// 		}
		// }
	}

	private function waitForEvent()
	{
		if (objects.doPumpEvents(onBreakpoint, onException, onUnknownStop))
		{
			dbgThread.events.cancel(waitLoop);

			waitLoop = null;
		}
	}

	private function noop()
	{
		//
	}

	private function onException()
	{
		trace('exception');
	}

	private function onBreakpoint()
	{
		trace('breakpoint');
	}

	private function onUnknownStop()
	{
		trace('unknown stop');
	}
}