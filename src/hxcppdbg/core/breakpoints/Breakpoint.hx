package hxcppdbg.core.breakpoints;

class Breakpoint
{
    public final id : Int;

    public final file : String;

    public final line : Int;

    public final char : Int;

    public function new (_id, _file, _line, _char)
    {
        id   = _id;
        file = _file;
        line = _line;
        char = _char;
    }
}