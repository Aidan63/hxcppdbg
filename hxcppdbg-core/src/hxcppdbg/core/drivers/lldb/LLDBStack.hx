package hxcppdbg.core.drivers.lldb;

import sys.thread.EventLoop;
import haxe.Exception;
import hxcppdbg.core.ds.Path;
import hxcppdbg.core.ds.Lazy;
import hxcppdbg.core.ds.Result;
import hxcppdbg.core.stack.NativeFrame;
import haxe.exceptions.NotImplementedException;
import hxcppdbg.core.drivers.lldb.native.LLDBContext;

class LLDBStack implements IStack
{
    final ctx : Lazy<cpp.Pointer<LLDBContext>>;

    final dbgThread : EventLoop;

    final cbThread : EventLoop;

    public function new(_ctx, _dbgThread, _cbThread)
    {
        ctx       = _ctx;
        dbgThread = _dbgThread;
        cbThread  = _cbThread;
    }

	public function getCallStack(_thread : Int, _callback : Result<Array<NativeFrame>, Exception>->Void) : Void
    {
		dbgThread.run(() -> {
            final result = try
            {
                Result.Success(ctx.value.ptr.getStackFrames(_thread).map(nativeFrameFromLLDB));
            }
            catch (err : String)
            {
                Result.Error(new Exception(err));
            }

            cbThread.run(() -> _callback(result));
        });
	}

    public function getFrame(_thread : Int, _index : Int, _callback : Result<NativeFrame, Exception>->Void) : Void
    {
		dbgThread.run(() -> {
            final result = try
            {
                Result.Success(nativeFrameFromLLDB(ctx.value.ptr.getStackFrame(_thread, _index)));
            }
            catch (err : String)
            {
                Result.Error(new Exception(err));
            }

            cbThread.run(() -> _callback(result));
        });
	}

    static function nativeFrameFromLLDB(_lldb : LLDBFrame)
    {
        return new NativeFrame(Path.of(_lldb.path), _lldb.symbol, _lldb.line);
    }
}