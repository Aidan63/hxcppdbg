package hxcppdbg.core.drivers.dbgeng;

import hxcppdbg.core.drivers.dbgeng.native.NativeModelData;
import hxcppdbg.core.model.ModelData;
import cpp.Pointer;
import sys.thread.Thread;
import sys.thread.EventLoop.EventHandler;
import haxe.Exception;
import haxe.ds.Option;
import hxcppdbg.core.ds.Result;
import hxcppdbg.core.drivers.Driver.BreakReason;
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

	public function start(_callback : Result<(Result<BreakReason, Exception>->Void)->Void, Exception>->Void)
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

	public function resume(_callback : Result<(Result<BreakReason, Exception>->Void)->Void, Exception>->Void)
	{
		start(_callback);
	}

	public function pause(_callback : Result<Bool, Exception>->Void)
	{
		try
		{
			if (objects.ptr.interrupt())
			{
				// Interrupt issued, queue up a task on the dbg thread to invoke the callback.
				// This ensures the callback is not invoked before process has actually been paused.
				dbgThread.events.run(() -> {
					cbThread.events.run(() -> _callback(Result.Success(true)));
				});
			}
			else
			{
				_callback(Result.Success(false));
			}
		}
		catch (error : String)
		{
			_callback(Result.Error(new Exception(error)));
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

	public function step(_thread : Int, _type : StepType, _callback : Result<(Result<BreakReason, Exception>->Void)->Void, Exception>->Void)
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

	function run(_callback : Result<BreakReason, Exception>->Void)
	{
		dbgThread.events.run(() -> {

			function onBreakpoint(_threadIdx : Int, _id : Int)
			{
				cbThread.events.run(() -> _callback(Result.Success(BreakReason.Breakpoint(_threadIdx, _id))));
			}

			function onException(_threadIdx : Int, _code : Int, _thrown : Null<NativeModelData>)
			{
				cbThread.events.run(() -> _callback(Result.Success(BreakReason.Exception(_threadIdx, if (_thrown != null) Option.Some(_thrown.toModelData()) else Option.None))));
			}

			function onPaused()
			{
				cbThread.events.run(() -> _callback(Result.Success(BreakReason.Paused)));
			}

			function onExited(_exitCode : Int)
			{
				cbThread.events.run(() -> _callback(Result.Success(BreakReason.Exited(_exitCode))));
			}

			try
			{
				objects.ptr.wait(onBreakpoint, onException, onPaused, onExited);
			}
			catch (error : String)
			{
				cbThread.events.run(() -> _callback(Result.Error(new Exception(error))));
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