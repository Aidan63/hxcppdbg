package hxcppdbg.core.drivers.dbgeng;

import hxcppdbg.core.ds.Result;
import cpp.Pointer;
import sys.thread.Thread;
import sys.thread.EventLoop.EventHandler;
import haxe.Exception;
import haxe.ds.Option;
import haxe.exceptions.NotImplementedException;
import hxcppdbg.core.drivers.dbgeng.native.DbgEngObjects;

using hxcppdbg.core.utils.ResultUtils;
using hxcppdbg.core.utils.OptionUtils;

class DbgEngDriver extends Driver
{
	final objects : Pointer<DbgEngObjects>;

	final cbThread : Thread;

	final dbgThread : Thread;

	var heartbeat : Null<EventHandler>;

	var pausedFlag : Bool;

	public function new(_file, _enums, _classes)
	{
		objects     = DbgEngObjects.alloc();
		cbThread    = Thread.current();
		dbgThread   = Thread.createWithEventLoop(() -> {
			switch objects.ptr.createFromFile(_file, _enums, _classes)
			{
				case Some(v):
					throw v;
				case None:
					heartbeat = Thread.current().events.repeat(noop, 1000);
			};
		});

		breakpoints = new DbgEngBreakpoints(objects, cbThread, dbgThread);
		stack       = new DbgEngStack(objects, cbThread, dbgThread);
		locals      = new DbgEngLocals(objects, cbThread, dbgThread);
		pausedFlag  = false;
	}

	public function start(_result : Option<Exception>->Void)
	{
		dbgThread.events.run(() -> {
			final r = objects.ptr.go();

			cbThread.events.run(() -> _result(r.asExceptionOption()));

			if (r.match(Option.None))
			{
				pausedFlag = false;

				switch objects.ptr.wait()
				{
					case Complete:
						trace('completed');
					case WaitFailed:
						trace('wait failed');
					case Interrupted(reason):
						switch reason
						{
							case Breakpoint(_, _):
								onBreakpoint();
							case Exception(_, _):
								onException();
							case Unknown:
								onUnknownStop();
							case Pause:
								pausedFlag = true;
						}
				}
			}
		});
	}

	public function resume(_result : Option<Exception>->Void)
	{
		start(_result);
	}

	public function pause(_result : Result<Bool, Exception>->Void)
	{
		switch objects.ptr.interrupt()
		{
			case Error(exn):
				_result(Result.Error(exn));
			case Success(paused):
				if (paused == 0)
				{
					_result(Result.Success(false));
				}
				else
				{
					dbgThread.events.run(() -> {
						final r = objects.ptr.pause();
			
						cbThread.events.run(() -> {
							switch r
							{
								case Some(exn):
									_result(Result.Error(exn));
								case None:
									_result(Result.Success(true));
							}
						});
					});
				}
		}
	}

	public function stop(_result : Option<Exception>->Void)
	{
		_result(Option.Some(new NotImplementedException()));
	}

	public function step(_thread : Int, _type : StepType, _result : Option<Exception>->Void)
	{
		dbgThread.events.run(() -> {
			switch objects.ptr.step(_thread, _type)
			{
				case Some(exn):
					cbThread.events.run(() -> _result(Option.Some(exn)));
				case None:
					pausedFlag = false;

					switch objects.ptr.wait()
					{
						case WaitFailed:
							cbThread.events.run(() -> _result(Option.Some(new Exception('Wait failed'))));
						case Complete:
							cbThread.events.run(() -> _result(Option.None));
						case Interrupted(reason):
							switch reason
							{
								case Breakpoint(_, _):
									cbThread.events.run(() -> {
										onBreakpoint();

										_result(Option.Some(new Exception('Breakpoint hit')));
									});
								case Exception(_, _):
									cbThread.events.run(() -> {
										onException();

										_result(Option.Some(new Exception('Exception thrown')));
									});
								case Unknown:
									cbThread.events.run(() -> {
										onUnknownStop();

										_result(Option.Some(new Exception('Unknown stop')));
									});
								case Pause:
									pausedFlag = true;

									_result(Option.Some(new Exception('interrupt')));
							}
					}
			}
		});
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