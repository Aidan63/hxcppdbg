package hxcppdbg.core.stack;

import hxcppdbg.core.drivers.IStack;

class Stack
{
    final driver : IStack;

    public function new(_driver)
    {
        driver = _driver;
    }

    public function getCallStack(_threadID)
    {
        for (frame in driver.getCallStack(_threadID))
        {
            trace(frame.func);
        }
    }
}