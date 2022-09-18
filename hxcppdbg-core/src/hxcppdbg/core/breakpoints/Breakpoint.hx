package hxcppdbg.core.breakpoints;

import hxcppdbg.core.ds.Path;

class Breakpoint
{
    public final id : Int;

    public final file : Path;

    public final line : Int;

    public final char : Int;

    public final native : Array<Int>;

    public function new (_id, _file, _line, _char, _native)
    {
        id     = _id;
        file   = _file;
        line   = _line;
        char   = _char;
        native = _native;
    }
}