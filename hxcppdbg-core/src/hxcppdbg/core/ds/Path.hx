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
        return switch (cast this : Path).isAbsolute
        {
            case true:
                switch _other.isAbsolute
                {
                    case true:
                        (cast this : Path).toString() == _other.toString();
                    case false:
                        (cast this : Path).toString().endsWith(_other.toString());
                }
            case false:
                switch _other.isAbsolute
                {
                    case true:
                        _other.toString().endsWith((cast this : Path).toString());
                    case false:
                        return (cast this : Path).toString().endsWith(_other.toString()) || _other.toString().endsWith((cast this : Path).toString());
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
            first.substr(0, 1).toLowerCase() + first.substr(1);
        }
        else
        {
            first;
        }
    }
}