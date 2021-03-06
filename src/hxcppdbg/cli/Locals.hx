package hxcppdbg.cli;

import hxcppdbg.core.locals.Locals in CoreLocals;
import hxcppdbg.core.model.Printer;

using Lambda;
using StringTools;

class Locals
{
    final locals : CoreLocals;

    public var native = false;

    public var json = false;

    public function new(_locals)
    {
        locals = _locals;
    }

    @:command public function list()
    {
        switch locals.getLocals(0, 0)
        {
            case Success(vars):
                for (hxVar in vars)
                {
                    switch hxVar
                    {
                        case Native(_):
                            continue;
                        case Haxe(model):
                            Sys.println('\t${ printModelData(model.key) }\t${ if (json) printModelData(model.data) else '' }');
                    }
                }
            case Error(e):
                Sys.println('\tError : ${ e.message }');
        }
    }

    @:defaultCommand public function help()
    {
        //
    }
}