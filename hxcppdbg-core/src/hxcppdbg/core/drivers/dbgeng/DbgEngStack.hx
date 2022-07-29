package hxcppdbg.core.drivers.dbgeng;

import haxe.Exception;
import sys.thread.Thread;
import hxcppdbg.core.ds.Result;
import hxcppdbg.core.stack.NativeFrame;
import hxcppdbg.core.drivers.dbgeng.native.DbgEngObjects;

using Lambda;
using StringTools;
using hxcppdbg.core.utils.ResultUtils;

class DbgEngStack implements IStack
{
    final objects : DbgEngObjects;

    final cbThread : Thread;

	final dbgThread : Thread;
    
	public function new(_objects, _cbThread, _dbgThread)
    {
        objects   = _objects;
        cbThread  = _cbThread;
        dbgThread = _dbgThread;
	}

    public function getCallStack(_thread : Int, _result : Result<Array<NativeFrame>, Exception>->Void)
    {
        dbgThread.events.run(() -> {
            final r = objects.getCallStack(_thread).map(item -> item.frame);

            cbThread.events.run(() -> _result(r.asExceptionResult()));
        });
    }

    public function getFrame(_thread : Int, _index : Int, _result : Result<NativeFrame, Exception>->Void)
    {
        dbgThread.events.run(() -> {
            final r = objects.getFrame(_thread, _index).apply(item -> item.frame);

            cbThread.events.run(() -> _result(r.asExceptionResult()));
        });
    }
}