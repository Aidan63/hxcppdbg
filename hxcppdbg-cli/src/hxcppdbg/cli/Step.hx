package hxcppdbg.cli;

import haxe.ds.Option;
import tink.CoreApi.Error;
import tink.CoreApi.Future;
import tink.cli.Prompt;
import tink.core.Promise;
import hxcppdbg.cli.Utils;
import hxcppdbg.core.Session;
import hxcppdbg.core.StepType;
import hxcppdbg.core.drivers.Interrupt;

class Step
{
    final session : Session;

    public var thread = 0;

    public function new(_session)
    {
        session = _session;
    }

    @:defaultCommand('in') public function step(_prompt : Prompt)
    {
        return stepPromise(_prompt, In);
    }

    @:command public function out(_prompt : Prompt)
    {
        return stepPromise(_prompt, Out);
    }

    @:command public function over(_prompt : Prompt)
    {
        return stepPromise(_prompt, Over);
    }

    @:command public function help()
    {
        //
    }

    function stepPromise(_prompt : Prompt, _step : StepType)
    {
        return
            Promise
                .irreversible((_resolve, _reject) -> {
                    session.step(thread, _step, result -> {
                        switch result
                        {
                            case Success(opt):
                                _resolve(opt);
                            case Error(exn):
                                _reject(new Error(exn.message));
                        }
                    });
                })
                .next(onStopReason)
                .next(_prompt.println);
    }

    function onStopReason(_opt : Option<Interrupt>)
    {
        return switch _opt
        {
            case Some(interrupt):
                printStopReason(session, interrupt);
            case None:
                printLocation();
        }
    }

    function printLocation()
    {
        return
            Future
                .irreversible(_handle -> {
                    session.stack.getFrame(thread, 0, result -> {
                        switch result
                        {
                            case Success(v):
                                switch v
                                {
                                    case Haxe(haxe, _):
                                        _handle('Thread $thread at ${ haxe.file.haxe } Line ${ haxe.expr.haxe.start.line }');
                                    case Native(_):
                                        // We should never end up in a native function.
                                        // Eventually a native flag might be added which means we could.
                                        // We could also step out of the haxe main so maybe we should continue running the program (and check for exit).
                                        _handle('Location is a native frame');
                        
                                }
                            case Error(e):
                                _handle(e.message);
                        }
                    });
                });
    }
}