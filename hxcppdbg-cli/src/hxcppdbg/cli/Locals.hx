package hxcppdbg.cli;

import tink.CoreApi.Noise;
import tink.CoreApi.Error;
import tink.CoreApi.Promise;
import hxcppdbg.core.locals.Locals in CoreLocals;
import hxcppdbg.core.model.Printer;

using Lambda;
using StringTools;

class Locals
{
    final locals : CoreLocals;

    public var native = false;

    public var json = false;

    public var thread = 0;

    public var frame = 0;

    public function new(_locals)
    {
        locals = _locals;
    }

    @:command public function list()
    {
        return Promise.irreversible((_resolve : Noise->Void, _reject : Error->Void) -> {
            locals.getLocals(thread, frame, result -> {
                switch result
                {
                    case Success(vars):
                        for (hxVar in vars)
                        {
                            switch hxVar
                            {
                                case Native(model):
                                    if (native)
                                    {
                                        Sys.println('\t[native]${ printModelData(model.key) }\t${ if (json) printModelData(model.data) else '' }');
                                    }
                                case Haxe(model):
                                    Sys.println('\t${ printModelData(model.key) }\t${ if (json) printModelData(model.data) else '' }');
                            }
                        }
                        _resolve(null);
                    case Error(exn):
                        _reject(new Error('\tError : ${ exn.message }'));
                }
            });
        });
    }

    @:defaultCommand public function help()
    {
        //
    }
}