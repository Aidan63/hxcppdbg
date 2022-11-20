package hxcppdbg.core.cache;

import haxe.Exception;
import hxcppdbg.core.ds.Result;

class Cache
{
    public final locals : LocalCache;

    public var stopReason : Result<StopReason, Exception>;

    public function new()
    {
        locals     = [];
        stopReason = Result.Error(new Exception("Target not suspended"));
    }

    public function clear()
    {
        locals.clear();
        stopReason = Result.Error(new Exception("Target not suspended"));
    }
}