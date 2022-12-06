package hxcppdbg.core.drivers.dbgeng;

import cpp.Pointer;
import sys.thread.Thread;
import sys.thread.EventLoop.EventHandler;
import haxe.Exception;
import haxe.ds.Option;
import hxcppdbg.core.ds.Result;
import hxcppdbg.core.drivers.Driver.BreakReason;
import hxcppdbg.core.drivers.dbgeng.native.DbgEngSession;
import hxcppdbg.core.drivers.dbgeng.native.DbgEngContext;
import hxcppdbg.core.drivers.dbgeng.native.NativeModelData;

using hxcppdbg.core.utils.ResultUtils;
using hxcppdbg.core.utils.OptionUtils;

class DbgEngDriver extends Driver
{
	final session : Pointer<DbgEngSession>;

	final cbThread : Thread;

	final dbgThread : Thread;

	final heartbeat : EventHandler;

	function new(_session, _cbThread, _threadIds)
	{
		session   = _session;
		cbThread  = _cbThread;
		dbgThread = Thread.current();
		heartbeat = Thread.current().events.repeat(noop, 1000);

		breakpoints = new DbgEngBreakpoints(session, cbThread, dbgThread);
		stack       = new DbgEngStack(session, cbThread, dbgThread);
		locals      = new DbgEngLocals(session, cbThread, dbgThread);
		threads     = new DbgEngThreads(session, cbThread, dbgThread, _threadIds);
	}

	public function start(_callback : Result<(Result<BreakReason, Exception>->Void)->Void, Exception>->Void)
	{
		dbgThread.events.run(() -> {
			final result = try
			{
				session.ptr.go();

				Result.Success(run);
			}
			catch (exn : String)
			{
				Result.Error(new Exception(exn));
			}
			
			cbThread.events.run(() -> _callback(result));
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
			if (session.ptr.interrupt())
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
			final result = try
			{
				session.ptr.end();

				session.destroy();

				dbgThread.events.cancel(heartbeat);

				Option.None;
			}
			catch (exn : String)
			{
				Option.Some(new Exception(exn));
			}

			cbThread.events.run(() -> _callback(result));
		});
	}

	public function step(_thread : Int, _type : StepType, _callback : Result<(Result<BreakReason, Exception>->Void)->Void, Exception>->Void)
	{
		dbgThread.events.run(() -> {
			final result = try
			{
				session.ptr.step(_thread, _type);

				Result.Success(run);
			}
			catch (exn : String)
			{
				Result.Error(new Exception(exn));
			}
			
			cbThread.events.run(() -> _callback(result));
		});
	}

	function run(_callback : Result<BreakReason, Exception>->Void)
	{
		dbgThread.events.run(() -> {

			var onBreakpoint    = null;
			var onException     = null;
			var onPaused        = null;
			var onExited        = null;
			var onThreadCreated = null;
			var onThreadExited  = null;

			onBreakpoint = function(_threadIdx : Int, _id : Int)
			{
				cbThread.events.run(() -> _callback(Result.Success(BreakReason.Breakpoint(_threadIdx, _id))));
			}

			onException = function(_threadIdx : Int, _code : Int, _thrown : Null<NativeModelData>)
			{
				cbThread.events.run(() -> _callback(Result.Success(BreakReason.Exception(_threadIdx, if (_thrown != null) Option.Some(_thrown.toModelData()) else Option.None))));
			}

			onPaused = function()
			{
				cbThread.events.run(() -> _callback(Result.Success(BreakReason.Paused)));
			}

			onExited = function(_exitCode : Int)
			{
				cbThread.events.run(() -> _callback(Result.Success(BreakReason.Exited(_exitCode))));
			}

			onThreadCreated = function()
			{
				cbThread.events.run(() -> (cast threads : DbgEngThreads).incrementThreadCount());

				try
				{
					session.ptr.go();
					session.ptr.wait(onBreakpoint, onException, onPaused, onExited, onThreadCreated, onThreadExited);
				}
				catch (error : String)
				{
					trace('err');

					cbThread.events.run(() -> _callback(Result.Error(new Exception(error))));
				}
			}

			onThreadExited = function()
			{
				cbThread.events.run(() -> (cast threads : DbgEngThreads).decrementThreadCount());

				try
				{
					session.ptr.go();
					session.ptr.wait(onBreakpoint, onException, onPaused, onExited, onThreadCreated, onThreadExited);
				}
				catch (error : String)
				{
					cbThread.events.run(() -> _callback(Result.Error(new Exception(error))));
				}
			}

			try
			{
				session.ptr.wait(onBreakpoint, onException, onPaused, onExited, onThreadCreated, onThreadExited);
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
			final result = 
				try
				{
					final ctx     = DbgEngContext.get();
					final session = ctx.ptr.start(_file, _enums, _classes);
					final ids     = session.ptr.getThreads().length;

					Result.Success(new DbgEngDriver(session, cbThread, ids));
				}
				catch (exn : String)
				{
					Result.Error(new Exception(exn));
				}

			cbThread.events.run(() -> _callback(result));
		});
	}

	static function noop()
	{
		//
	}
}