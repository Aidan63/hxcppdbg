package hxcppdbg.core.drivers.dbgeng;

import haxe.ds.Option;
import haxe.Exception;
import hxcppdbg.core.ds.Result;
import sys.thread.Thread;
import hxcppdbg.core.drivers.dbgeng.native.DbgEngObjects;

using hxcppdbg.core.utils.ResultUtils;
using hxcppdbg.core.utils.OptionUtils;

class DbgEngBreakpoints implements IBreakpoints
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
    
	public function create(_file : String, _line : Int, _result : Result<Int, Exception>->Void)
    {
        dbgThread.events.run(() -> {
            final r = objects.createBreakpoint(_file, _line);

            cbThread.events.run(() -> _result(r.asExceptionResult()));
        });
	}

	public function remove(_id : Int, _result : Option<Exception>->Void)
    {
        dbgThread.events.run(() -> {
            final r = objects.removeBreakpoint(_id);

            cbThread.events.run(() -> _result(r.asExceptionOption()));
        });
	}
}