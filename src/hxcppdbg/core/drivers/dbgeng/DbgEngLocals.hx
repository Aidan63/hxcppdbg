package hxcppdbg.core.drivers.dbgeng;

import hxcppdbg.core.locals.NativeLocal;
import hxcppdbg.core.drivers.dbgeng.native.RawFrameLocal;
import hxcppdbg.core.drivers.dbgeng.native.DbgEngObjects;

using Lambda;

class DbgEngLocals implements ILocals
{
    final driver : DbgEngObjects;

    public function new(_driver)
    {
        driver = _driver;
    }

	public function getVariables(_thread : Int, _frame : Int)
    {
        return driver.getVariables(_thread, _frame).map(toNativeLocal);
    }

	public function getArguments(_thread : Int, _frame : Int)
    {
        driver.getArguments(_thread, _frame);
    }

    function toNativeLocal(_input : RawFrameLocal)
    {
        return new NativeLocal(_input.name, _input.type, _input.value);
    }
}