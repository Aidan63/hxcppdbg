package hxcppdbg.core.drivers.dbgeng;

import cpp.Pointer;
import sys.thread.Thread;
import haxe.Int64;
import haxe.Exception;
import haxe.ds.Option;
import hxcppdbg.core.ds.Result;
import hxcppdbg.core.drivers.dbgeng.native.DbgEngContext;

using hxcppdbg.core.utils.ResultUtils;
using hxcppdbg.core.utils.OptionUtils;

class DbgEngBreakpoints implements IBreakpoints
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
    
	public function create(_file : String, _line : Int, _callback : Result<Int64, Exception>->Void)
    {
        dbgThread.events.run(() -> {
            final result = try
            {
                Result.Success(objects.ptr.createBreakpoint(_file, _line));
            }
            catch (error : String)
            {
                Result.Error(new Exception(error));
            }

            cbThread.events.run(() -> _callback(result));
        });
	}

	public function remove(_id : Int64, _callback : Option<Exception>->Void)
    {
        dbgThread.events.run(() -> {
            final result = try
            {
                objects.ptr.removeBreakpoint(_id);

                Option.None;
            }
            catch (error : String)
            {
                Option.Some(new Exception(error));
            }

            cbThread.events.run(() -> _callback(result));
        });
	}
}