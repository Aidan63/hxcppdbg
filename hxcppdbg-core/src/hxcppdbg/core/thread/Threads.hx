package hxcppdbg.core.thread;

import tink.CoreApi.SignalTrigger;
import haxe.Exception;
import hxcppdbg.core.ds.Result;
import hxcppdbg.core.drivers.IThreads;

class Threads
{
    final driver : IThreads;

    final threads : Array<NativeThread>;

    public final created : SignalTrigger<Int>;

    public final exited : SignalTrigger<Int>;

    public function new(_driver)
    {
        driver  = _driver;
        threads = [];
        created = driver.getCreatedSignal();
        exited  = driver.getExitedSignal();
    }

    public function getThreads(_callback : Result<Array<NativeThread>, Exception>->Void)
    {
        driver.getThreads(_callback);
    }
}