package hxcppdbg.core.drivers.lldb;

import haxe.Int64;
import sys.thread.Thread;
import sys.thread.EventLoop;
import haxe.exceptions.NotImplementedException;
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

	public function create(_file : String, _line : Int, _callback : Result<Int, Exception>->Void) : Void
    {
		dbgThread.run(() -> {
            final result = try
            {
                Result.Success(ctx.ptr.createBreakpoint(_file, _line).low);
            }
            catch (err : String)
            {
                Result.Error(new Exception(err));
            }

            cbThread.run(() -> _callback(result));
        });
	}

	public function remove(_id : Int, _callback : Option<Exception>->Void) : Void
    {
        dbgThread.run(() -> {
            final error = if (ctx.ptr.removeBreakpoint(Int64.make(0, _id)))
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