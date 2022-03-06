package hxcppdbg.cli;

import hxcppdbg.core.sourcemap.Sourcemap;
import hxcppdbg.core.locals.Locals in CoreLocals;

using Lambda;
using StringTools;

class Locals
{
    final locals : CoreLocals;

    public var native = false;

    public function new(_locals)
    {
        locals = _locals;
    }

    @:command public function list()
    {
        for (hxVar in locals.getLocals(0, 0))
        {
            switch hxVar
            {
                case Native(_):
                    continue;
                case Haxe(_haxe, _native):
                    Sys.println('\t${ _haxe.haxe }\t\t${ _haxe.type }\t\t${ _native.value }');
            }
        }
    }

    @:defaultCommand public function help()
    {
        //
    }
}