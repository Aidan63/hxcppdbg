package hxcppdbg.core.drivers;

import haxe.Exception;
import hxcppdbg.core.ds.Result;
import hxcppdbg.core.thread.NativeThread;

interface IThreads
{
    function getThreads(_result : Result<Array<NativeThread>, Exception>->Void) : Void;
}