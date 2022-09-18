package hxcppdbg.core.drivers.dbgeng;

import hxcppdbg.core.ds.Result;
import cpp.Pointer;
import sys.thread.Thread;
import sys.thread.EventLoop.EventHandler;
import haxe.Exception;
import haxe.ds.Option;
import hxcppdbg.core.drivers.dbgeng.native.DbgEngContext;

using hxcppdbg.core.utils.ResultUtils;
using hxcppdbg.core.utils.OptionUtils;

class DbgEngDriver extends Driver
{
	final objects : Pointer<DbgEngContext>;

	final cbThread : Thread;

	final dbgThread : Thread;

	final heartbeat : EventHandler;

	function new(_objects, _cbThread)
	{
		objects   = _objects;
		cbThread  = _cbThread;
		dbgThread = Thread.current();
		heartbeat = Thread.current().events.repeat(noop, 1000);

		breakpoints = new DbgEngBreakpoints(objects, cbThread, dbgThread);
		stack       = new DbgEngStack(objects, cbThread, dbgThread);
		locals      = new DbgEngLocals(objects, cbThread, dbgThread);
		threads     = new DbgEngThreads(objects, cbThread, dbgThread);
	}

	public function start(_callback : Result<(Result<Option<Interrupt>, Exception>->Void)->Void, Exception>->Void)
	{
		dbgThread.events.run(() -> {
			switch objects.ptr.go()
			{
				case Some(exn):
					cbThread.events.run(() -> _callback(Result.Error(exn)));
				case None:
					cbThread.events.run(() -> _callback(Result.Success(run)));
			}
		});
	}

	public function resume(_callback : Result<(Result<Option<Interrupt>, Exception>->Void)->Void, Exception>->Void)
	{
		start(_callback);
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

	public function stop(_callback : Option<Exception>->Void)
	{
		dbgThread.events.run(() -> {
			switch objects.ptr.end()
			{
				case Some(exn):
					cbThread.events.run(() -> _callback(Option.Some(exn)));

					objects.destroy();

					dbgThread.events.cancel(heartbeat);
				case None:
					cbThread.events.run(() -> _callback(Option.None));
			}
		});
	}

	public function step(_thread : Int, _type : StepType, _callback : Result<(Result<Option<Interrupt>, Exception>->Void)->Void, Exception>->Void)
	{
		dbgThread.events.run(() -> {
			switch objects.ptr.step(_thread, _type)
			{
				case Some(exn):
					cbThread.events.run(() -> _callback(Result.Error(exn)));
				case None:
					cbThread.events.run(() -> _callback(Result.Success(run)));
			}
		});
	}

	function run(_callback : Result<Option<Interrupt>, Exception>->Void)
	{
		dbgThread.events.run(() -> {
			switch objects.ptr.wait()
			{
				case Complete:
					cbThread.events.run(() -> _callback(Result.Success(Option.None)));
				case WaitFailed:
					cbThread.events.run(() -> _callback(Result.Error(new Exception('Wait failed'))));
				case Interrupted(reason):
					cbThread.events.run(() -> {
						switch reason
						{
							case Breakpoint(idx, id):
								_callback(Result.Success(Option.Some(Interrupt.BreakpointHit(idx, id))));
							case Exception(idx, _):
								_callback(Result.Success(Option.Some(Interrupt.ExceptionThrown(idx))));
							case Unknown, Pause:
								_callback(Result.Success(Option.Some(Interrupt.Other)));
						}
					});
			}
		});
	}

	public static function create(_file, _enums, _classes, _callback : Result<DbgEngDriver, Exception>->Void)
	{
		final cbThread = Thread.current();

		Thread.createWithEventLoop(() -> {
			final ctx    = DbgEngContext.alloc();
			final result = switch ctx.ptr.createFromFile(_file, _enums, _classes)
			{
				case Some(exn):
					Result.Error((exn : Exception));
				case None:
					Result.Success(new DbgEngDriver(ctx, cbThread));
			}

			cbThread.events.run(() -> _callback(result));
		});
	}

	static function noop()
	{
		//
	}
}