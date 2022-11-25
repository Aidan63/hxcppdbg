package hxcppdbg.core.drivers.dbgeng;

import cpp.Pointer;
import sys.thread.Thread;
import haxe.Exception;
import hxcppdbg.core.ds.Result;
import hxcppdbg.core.drivers.dbgeng.native.DbgEngSession;
import hxcppdbg.core.thread.NativeThread;

using Lambda;

class DbgEngThreads implements IThreads
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

    public function getThreads(_result : Result<Array<NativeThread>, Exception>->Void)
    {
        dbgThread.events.run(() -> {
            final result =
                try
                {
                    Result.Success(objects.ptr.getThreads().mapi((idx, id) -> new NativeThread(idx, 'Thread $idx')));
                }
                catch (exn : String)
                {
                    Result.Error(new Exception(exn));
                }
                
            cbThread.events.run(() -> _result(result));
        });
    }
}