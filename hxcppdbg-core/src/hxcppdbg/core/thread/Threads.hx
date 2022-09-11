package hxcppdbg.core.thread;

import haxe.Exception;
import hxcppdbg.core.ds.Result;
import hxcppdbg.core.drivers.IThreads;

class Threads
{
    final driver : IThreads;

    public function new(_driver)
    {
        driver = _driver;
    }

    public function getThreads(_callback : Result<Array<NativeThread>, Exception>->Void)
    {
        driver.getThreads(_callback);
    }
}