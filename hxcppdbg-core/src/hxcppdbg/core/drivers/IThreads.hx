package hxcppdbg.core.drivers;

import tink.CoreApi.SignalTrigger;
import haxe.Exception;
import hxcppdbg.core.ds.Result;
import hxcppdbg.core.thread.NativeThread;

interface IThreads
{
    function getThreads(_result : Result<Array<NativeThread>, Exception>->Void) : Void;

    function getCreatedSignal() : SignalTrigger<Int>;

    function getExitedSignal() : SignalTrigger<Int>;
}