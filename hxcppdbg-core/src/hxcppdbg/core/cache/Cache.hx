package hxcppdbg.core.cache;

class Cache
{
    public final locals : LocalCache;

    public function new()
    {
        locals = [];
    }

    public function clear()
    {
        locals.clear();
    }
}