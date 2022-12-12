package hxcppdbg.core.drivers.dbgeng;

import tink.CoreApi.SignalTrigger;
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

    final threadCreated : SignalTrigger<Int>;

    final threadExited : SignalTrigger<Int>;

    final activeThreads : Array<Int>;

    public function new(_objects, _cbThread, _dbgThread)
    {
        objects       = _objects;
        cbThread      = _cbThread;
        dbgThread     = _dbgThread;
        threadCreated = new SignalTrigger();
        threadExited  = new SignalTrigger();
        activeThreads = [];
    }

    public function getThreads(_callback : Result<Array<NativeThread>, Exception>->Void)
    {
        cbThread.events.run(() -> {
            _callback(Result.Success([ for (i in 0...activeThreads.length) new NativeThread('Thread $i') ]));
        });
    }

    public function getCreatedSignal()
    {
        return threadCreated;
    }

    public function getExitedSignal()
    {
        return threadExited;
    }

    public function onThreadCreated(_id)
    {
        activeThreads.push(_id);

        threadCreated.trigger(activeThreads.length - 1);
    }

    public function onThreadExited(_id)
    {
        switch activeThreads.findIndex(id -> id == _id)
        {
            case -1:
                //
            case idx:
                activeThreads.remove(_id);

                threadCreated.trigger(idx);
        }
    }
}