package hxcppdbg.core.drivers.dbgeng;

import haxe.exceptions.NotImplementedException;
import cpp.Pointer;
import sys.thread.Thread;
import haxe.Exception;
import hxcppdbg.core.ds.Result;
import hxcppdbg.core.model.Model;
import hxcppdbg.core.drivers.dbgeng.native.DbgEngContext;
import hxcppdbg.core.drivers.dbgeng.native.NativeModelData;

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
            final r =
                driver
                    .ptr
                    .getVariables(_thread, _frame)
                    .map(toModel);

            cbThread.events.run(() -> _callback(r.asExceptionResult()));
        });
    }

	public function getArguments(_thread : Int, _frame : Int, _callback : Result<Array<Model>, Exception>->Void)
    {
        _callback(Result.Error(new NotImplementedException()));
    }

    function toModel(_local : { name : String, data : NativeModelData }) : Model
    {
        return
            new Model(
                ModelData.MString(_local.name),
                NativeModelDataTools.toModelData(_local.data));
    }
}