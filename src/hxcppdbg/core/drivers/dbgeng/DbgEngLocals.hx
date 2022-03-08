package hxcppdbg.core.drivers.dbgeng;

import hxcppdbg.core.drivers.dbgeng.native.DbgEngObjects;

using Lambda;
using hxcppdbg.core.utils.ResultUtils;

class DbgEngLocals implements ILocals
{
    final driver : DbgEngObjects;

    public function new(_driver)
    {
        driver = _driver;
    }

	public function getVariables(_thread : Int, _frame : Int)
    {
        return driver.getVariables(_thread, _frame).asExceptionResult();
    }

	public function getArguments(_thread : Int, _frame : Int)
    {
        return driver.getArguments(_thread, _frame).asExceptionResult();
    }
}