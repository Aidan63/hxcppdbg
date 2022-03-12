package hxcppdbg.core.breakpoints;

import hxcppdbg.core.sourcemap.Sourcemap.ExprMap;

class Breakpoint
{
    public final id : Int;

    public final file : String;

    public final line : Int;

    public final char : Int;

    public final expr : ExprMap;

    public function new (_id, _file, _line, _char, _expr)
    {
        id   = _id;
        file = _file;
        line = _line;
        char = _char;
        expr = _expr;
    }
}