package hxcppdbg.core.drivers.lldb;

import haxe.exceptions.NotImplementedException;
import sys.thread.Thread;
import sys.thread.EventLoop;
import haxe.Exception;
import hxcppdbg.core.ds.Result;
import hxcppdbg.core.model.NamedModelData;
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

	public function getVariables(_thread : Int, _frame : Int, _callback : Result<IKeyable<String, NamedModelData>, Exception>->Void)
    {
        cbThread.run(() -> _callback(Result.Error(new NotImplementedException())));
	}

	public function getArguments(_thread : Int, _frame : Int, _callback : Result<IKeyable<String, NamedModelData>, Exception>->Void)
    {
        cbThread.run(() -> _callback(Result.Error(new NotImplementedException())));
    }
}