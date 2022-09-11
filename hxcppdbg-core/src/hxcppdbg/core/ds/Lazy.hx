package hxcppdbg.core.ds;

@:generic class Lazy<T>
{
    public var value (get, never) : T;

    var cached : Null<T>;

    final fetch : Void->T;

    public function new(_fetch)
    {
        cached = null;
        fetch  = _fetch;
    }

    function get_value()
    {
        return switch cached
        {
            case null:
                cached = fetch();
            case v:
                v;
        }
    }
}