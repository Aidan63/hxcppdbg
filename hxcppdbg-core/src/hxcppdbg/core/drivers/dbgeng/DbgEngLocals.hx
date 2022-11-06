package hxcppdbg.core.drivers.dbgeng;

import hxcppdbg.core.model.NamedModelData;
import hxcppdbg.core.drivers.dbgeng.native.NativeModelData;
import cpp.Pointer;
import sys.thread.Thread;
import haxe.Exception;
import haxe.exceptions.NotImplementedException;
import hxcppdbg.core.ds.Result;
import hxcppdbg.core.drivers.dbgeng.native.DbgEngContext;

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

	public function getVariables(_threadIndex : Int, _frameIndex : Int, _callback : Result<IKeyable<String, NamedModelData>, Exception>->Void)
    {
        dbgThread.events.run(() -> {
            final result = try
            {
                Result.Success(
                    (new DbgEngLocalStore(driver.ptr.getVariables(_threadIndex, _frameIndex)) : IKeyable<String, NamedModelData>)
                );
            }
            catch (exn)
            {
                Result.Error(exn);
            }

            cbThread.events.run(() -> _callback(result));
        });
    }
 
	public function getArguments(_thread : Int, _frame : Int, _callback : Result<IKeyable<String, NamedModelData>, Exception>->Void)
    {
        _callback(Result.Error(new NotImplementedException()));
    }
}