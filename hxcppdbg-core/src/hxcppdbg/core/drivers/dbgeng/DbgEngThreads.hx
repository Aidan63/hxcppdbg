package hxcppdbg.core.drivers.dbgeng;

import cpp.Pointer;
import sys.thread.Thread;
import haxe.Exception;
import hxcppdbg.core.ds.Result;
import hxcppdbg.core.thread.NativeThread;
import hxcppdbg.core.drivers.dbgeng.native.DbgEngSession;

using Lambda;

class DbgEngThreads implements IThreads
{
    final objects : Pointer<DbgEngSession>;

    final cbThread : Thread;

	final dbgThread : Thread;

    var activeThreads : Int;

    public function new(_objects, _cbThread, _dbgThread)
    {
        objects       = _objects;
        cbThread      = _cbThread;
        dbgThread     = _dbgThread;
        activeThreads = 1;
    }

    public function getThreads(_result : Result<Array<NativeThread>, Exception>->Void)
    {
        cbThread.events.run(() -> {
            final result =
                try
                {
                    Result.Success([ for (i in 0...activeThreads) new NativeThread(i, 'Thread $i')]);
                }
                catch (exn : String)
                {
                    Result.Error(new Exception(exn));
                }

            _result(result);
        });
    }

    public function incrementThreadCount()
    {
        activeThreads++;
    }

    public function decrementThreadCount()
    {
        activeThreads--;
    }
}