package hxcppdbg.core.drivers.lldb;

import sys.thread.Thread;
import sys.thread.EventLoop;
import haxe.Int64;
import haxe.Exception;
import haxe.ds.Option;
import hxcppdbg.core.ds.Result;
import hxcppdbg.core.drivers.lldb.native.LLDBContext;

class LLDBBreakpoints implements IBreakpoints
{
    final ctx : cpp.Pointer<LLDBContext>;

    final dbgThread : EventLoop;

    final cbThread : EventLoop;

    public function new(_ctx, _cbThread)
    {
        ctx       = _ctx;
        dbgThread = Thread.current().events;
        cbThread  = _cbThread;
    }

	public function create(_file : String, _line : Int, _callback : Result<Int64, Exception>->Void) : Void
    {
		dbgThread.run(() -> {
            final result = try
            {
                Result.Success(ctx.ptr.createBreakpoint(_file, _line));
            }
            catch (err : String)
            {
                Result.Error(new Exception(err));
            }

            cbThread.run(() -> _callback(result));
        });
	}

	public function remove(_id : Int64, _callback : Option<Exception>->Void) : Void
    {
        dbgThread.run(() -> {
            final error = if (ctx.ptr.removeBreakpoint(_id))
            {
                Option.None;
            }
            else
            {
                Option.Some(new Exception('Failed to remove breakpoint'));
            }

            cbThread.run(() -> _callback(error));
        });
    }
}