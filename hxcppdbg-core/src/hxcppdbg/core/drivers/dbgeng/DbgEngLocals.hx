package hxcppdbg.core.drivers.dbgeng;

import cpp.Pointer;
import hxcppdbg.core.drivers.dbgeng.native.DbgEngObjects;

using Lambda;
using hxcppdbg.core.utils.ResultUtils;

class DbgEngLocals implements ILocals
{
    final driver : Pointer<DbgEngObjects>;

    public function new(_driver)
    {
        driver = _driver;
    }

	public function getVariables(_thread : Int, _frame : Int)
    {
        return driver.ptr.getVariables(_thread, _frame).asExceptionResult();
    }

	public function getArguments(_thread : Int, _frame : Int)
    {
        return driver.ptr.getArguments(_thread, _frame).asExceptionResult();
    }
}