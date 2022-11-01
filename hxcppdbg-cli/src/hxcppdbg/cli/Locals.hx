package hxcppdbg.cli;

import tink.CoreApi.Error;
import tink.CoreApi.Promise;
import hxcppdbg.core.locals.Locals in CoreLocals;

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
                                _resolve(vars.getLocals());
                            case Error(exn):
                                _reject(new Error('Error : ${ exn.message }'));
                        }
                    });
                })
                .next(vars -> vars.join('\n'))
                .next(_prompt.println);
    }

    @:defaultCommand public function help()
    {
        //
    }
}