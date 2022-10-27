package hxcppdbg.cli;

import haxe.Timer;
import cpp.vm.Gc;
import sys.thread.Thread;
import hxcppdbg.core.locals.LocalVariable;
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

    @:command public function list(_prompt : tink.cli.Prompt)
    {
        return
            Promise
                .irreversible((_resolve, _reject) -> {
                    locals.getLocals(thread, frame, result -> {
                        switch result
                        {
                            case Success(vars):
                                _resolve(vars);
                            case Error(exn):
                                _reject(new Error('Error : ${ exn.message }'));
                        }
                    });
                })
                .next(vars -> vars.filter(filterLocalVariable).map(printLocalVariable).join('\n'))
                .next(_prompt.println);
    }

    @:defaultCommand public function help()
    {
        //
    }

    function filterLocalVariable(_local : LocalVariable)
    {
        return switch _local
        {
            case Native(_):
                native;
            case Haxe(_):
                true;
        }
    }

    function printLocalVariable(_local : LocalVariable)
    {
        return switch _local
        {
            case Native(model):
                '\t[native]${ printModelData(model.key) }\t${ if (json) printModelData(model.data) else '' }';
            case Haxe(model):
                '\t${ printModelData(model.key) }\t${ if (json) printModelData(model.data) else '' }';
        }
    }
}