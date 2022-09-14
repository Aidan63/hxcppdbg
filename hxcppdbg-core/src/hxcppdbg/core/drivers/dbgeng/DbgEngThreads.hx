package hxcppdbg.core.drivers.dbgeng;

import cpp.Pointer;
import sys.thread.Thread;
import haxe.Exception;
import hxcppdbg.core.ds.Result;
import hxcppdbg.core.drivers.dbgeng.native.DbgEngContext;
import hxcppdbg.core.thread.NativeThread;

using Lambda;

class DbgEngThreads implements IThreads
{
    final objects : Pointer<DbgEngContext>;

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
            switch objects.ptr.getThreads()
            {
                case Success(threads):
                    cbThread.events.run(() -> _result(Result.Success(threads.mapi((idx, _) -> new NativeThread(idx, 'Thread $idx')))));
                case Error(exn):
                    cbThread.events.run(() -> _result(Result.Error(exn)));
            }
        });
    }
}