package hxcppdbg.core.drivers.lldb;

import sys.thread.Thread;
import sys.thread.EventLoop;
import tink.CoreApi.SignalTrigger;
import haxe.Exception;
import hxcppdbg.core.ds.Result;
import hxcppdbg.core.thread.NativeThread;
import hxcppdbg.core.drivers.lldb.native.LLDBContext;

class LLDBThreads implements IThreads
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

	public function getThreads(_callback : Result<Array<NativeThread>, Exception>->Void)
    {
        dbgThread.run(() -> {
            final result = try
            {
                Result.Success(ctx.ptr.getThreads().map(t -> new NativeThread(t.name)));
            }
            catch (error : String)
            {
                Result.Error(new Exception(error));
            }

            cbThread.run(() -> _callback(result));
        });
    }

    public function getCreatedSignal()
    {
        return new SignalTrigger();
    }

    public function getExitedSignal()
    {
        return new SignalTrigger();
    }
}