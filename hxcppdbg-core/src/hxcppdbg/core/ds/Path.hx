package hxcppdbg.core.ds;

using StringTools;

@:forward(toString)
abstract Path(haxe.io.Path)
{
    function new(_input)
    {
        this = _input;
    }

    public function matches(_other : Path)
    {
        return switch abstract.isAbsolute
        {
            case true:
                switch _other.isAbsolute
                {
                    case true:
                        abstract.toString() == _other.toString();
                    case false:
                        abstract.toString().endsWith(_other.toString());
                }
            case false:
                switch _other.isAbsolute
                {
                    case true:
                        _other.toString().endsWith(abstract.toString());
                    case false:
                        return abstract.toString().endsWith(_other.toString()) || _other.toString().endsWith(abstract.toString());
                }
        }
    }

    public var isAbsolute (get, never) : Bool;

    function get_isAbsolute()
    {
        return haxe.io.Path.isAbsolute(this.toString());
    }

    public static function of(_input)
    {
        return new Path(new haxe.io.Path(normalise(_input)));
    }

    static function normalise(_input : String)
    {
        final first = haxe.io.Path.normalize(_input);

        return if (first.length >= 2 && first.fastCodeAt(1) == ':'.code)
        {
            first.substr(0, 1).toUpperCase() + first.substr(1);
        }
        else
        {
            first;
        }
    }
}