package hxcppdbg.core.drivers.dbgeng;

import sys.thread.Thread;
import sys.thread.EventLoop.EventHandler;
import haxe.Exception;
import haxe.ds.Option;
import haxe.exceptions.NotImplementedException;
import hxcppdbg.core.drivers.dbgeng.native.DbgEngObjects;

using hxcppdbg.core.utils.ResultUtils;
using hxcppdbg.core.utils.OptionUtils;

private enum abstract StepWaitLoopResult(Int) from Int
{
	var FailedToGetLastEvent;
	var WaitForEventFailed;
	var BreakpointHit;
	var ExceptionHit;
	var UnknownLastEvent;
	var StepComplete;
}

class DbgEngDriver extends Driver
{
	final objects : DbgEngObjects;

	final cbThread : Thread;

	final dbgThread : Thread;

	var heartbeat : Null<EventHandler>;

	var waitLoop : Null<EventHandler>;

	public function new(_file, _enums, _classes)
	{
		objects     = DbgEngObjects.alloc();
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

		breakpoints = new DbgEngBreakpoints(objects, cbThread, dbgThread);
		stack       = new DbgEngStack(objects, cbThread, dbgThread);
		locals      = new DbgEngLocals(objects);
	}

	public function start(_result : Option<Exception>->Void)
	{
		dbgThread.events.run(() -> {
			waitLoop = dbgThread.events.repeat(waitForEvent, 10);

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
		dbgThread.events.run(() -> {
			final r = objects.step(_thread, _type);

			if (r.match(Option.None))
			{
				function loop()
				{
					dbgThread.events.run(() -> {
						switch objects.stepEventWait()
						{
							case LoopAgain:
								loop();
							case WaitFailed:
								cbThread.events.run(() -> _result(Option.Some(new Exception('Wait Failed'))));
							case StepCompleted:
								cbThread.events.run(() -> _result(Option.None));
							case StepInterrupted(reason):
								cbThread.events.run(() -> {
									switch reason
									{
										case Breakpoint:
											onBreakpoint();
										case Exception:
											onException();
										case Unknown:
											onUnknownStop();
									}

									_result(Option.None);
								});
						}
					});
				}

				loop();
			}
			else
			{
				cbThread.events.run(() -> _result(r.asExceptionOption()));
			}
		});
	}

	private function waitForEvent()
	{
		if (objects.runEventWait(onBreakpoint, onException, onUnknownStop))
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