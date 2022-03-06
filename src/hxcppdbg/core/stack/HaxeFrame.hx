package hxcppdbg.core.stack;

import haxe.ds.Option;
import hxcppdbg.core.sourcemap.Sourcemap.ExprMap;
import hxcppdbg.core.sourcemap.Sourcemap.Closure;
import hxcppdbg.core.sourcemap.Sourcemap.Function;
import hxcppdbg.core.sourcemap.Sourcemap.GeneratedFile;

class HaxeFrame
{
    public final file : GeneratedFile;

    public final expr : ExprMap;

    public final func : Function;

    public final closure : Option<Closure>;

    public function new(_file, _expr, _func, _closure)
    {
        file    = _file;
        expr    = _expr;
        func    = _func;
        closure = _closure;
    }
}