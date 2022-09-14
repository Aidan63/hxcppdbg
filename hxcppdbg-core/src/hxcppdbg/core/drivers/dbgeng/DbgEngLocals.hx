package hxcppdbg.core.drivers.dbgeng;

import cpp.Pointer;
import sys.thread.Thread;
import haxe.Exception;
import hxcppdbg.core.ds.Result;
import hxcppdbg.core.model.Model;
import hxcppdbg.core.drivers.dbgeng.native.DbgEngContext;

using Lambda;
using hxcppdbg.core.utils.ResultUtils;

class DbgEngLocals implements ILocals
{
    final driver : Pointer<DbgEngContext>;

    final cbThread : Thread;

	final dbgThread : Thread;

    public function new(_driver, _cbThread, _dbgThread)
    {
        driver    = _driver;
        cbThread  = _cbThread;
        dbgThread = _dbgThread;
    }

	public function getVariables(_thread : Int, _frame : Int, _callback : Result<Array<Model>, Exception>->Void)
    {
        dbgThread.events.run(() -> {
            final r = driver.ptr.getVariables(_thread, _frame);

            cbThread.events.run(() -> _callback(r.asExceptionResult()));
        });
    }

	public function getArguments(_thread : Int, _frame : Int, _callback : Result<Array<Model>, Exception>->Void)
    {
        // dbgThread.events.run(() -> {
        //     final r = driver.ptr.getArguments(_thread, _frame);

        //     cbThread.events.run(() -> _callback(r.asExceptionResult()));
        // });
    }
}