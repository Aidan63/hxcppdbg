package hxcppdbg.core.drivers.lldb;

import sys.thread.Thread;
import sys.thread.EventLoop;
import haxe.Exception;
import hxcppdbg.core.ds.Result;
import hxcppdbg.core.model.Model;
import hxcppdbg.core.model.ModelData;
import hxcppdbg.core.drivers.lldb.native.LLDBContext;

class LLDBLocals implements ILocals
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

	public function getVariables(_thread : Int, _frame : Int, _callback : Result<Array<Model>, Exception>->Void) : Void
    {
        dbgThread.run(() -> {
            final result = try
            {
                Result.Success(ctx.ptr.getLocals(_thread, _frame).map(l -> new Model(MString(l.name), ModelData.MUnknown(l.type))));
            }
            catch (error : String)
            {
                Result.Error(new Exception(error));
            }

            cbThread.run(() -> _callback(result));
        });
	}

	public function getArguments(_thread : Int, _frame : Int, _callback : Result<Array<Model>, Exception>->Void) : Void
    {
        dbgThread.run(() -> {
            final result = try
            {
                Result.Success(ctx.ptr.getArguments(_thread, _frame).map(l -> new Model(MString(l.name), ModelData.MUnknown(l.type))));
            }
            catch (error : String)
            {
                Result.Error(new Exception(error));
            }

            cbThread.run(() -> _callback(result));
        });
    }
}