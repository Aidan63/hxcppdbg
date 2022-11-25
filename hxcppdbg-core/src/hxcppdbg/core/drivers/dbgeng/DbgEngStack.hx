package hxcppdbg.core.drivers.dbgeng;

import cpp.Pointer;
import haxe.Exception;
import sys.thread.Thread;
import hxcppdbg.core.ds.Path;
import hxcppdbg.core.ds.Result;
import hxcppdbg.core.stack.NativeFrame;
import hxcppdbg.core.drivers.dbgeng.native.DbgEngSession;

using Lambda;
using StringTools;
using hxcppdbg.core.utils.ResultUtils;

class DbgEngStack implements IStack
{
    final objects : Pointer<DbgEngSession>;

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
            final result =
                try
                {
                    Result.Success(objects.ptr.getCallStack(_thread).map(frame -> new NativeFrame(Path.of(frame.file), frame.func, frame.line)));
                }
                catch (exn : String)
                {
                    Result.Error(new Exception(exn));
                }

            cbThread.events.run(() -> _result(result));
        });
    }

    public function getFrame(_thread : Int, _index : Int, _result : Result<NativeFrame, Exception>->Void)
    {
        dbgThread.events.run(() -> {
            final result =
                try
                {
                    final frame = objects.ptr.getFrame(_thread, _index);

                    Result.Success(new NativeFrame(Path.of(frame.file), frame.func, frame.line));
                }

            cbThread.events.run(() -> _result(result));
        });
    }
}