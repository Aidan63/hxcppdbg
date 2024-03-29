package hxcppdbg.cli;

import haxe.ds.Option;
import tink.CoreApi.Noise;
import tink.CoreApi.Error;
import tink.CoreApi.Future;
import tink.CoreApi.Promise;
import hxcppdbg.cli.Utils;
import hxcppdbg.core.Session;

using Lambda;

class Hxcppdbg
{
    final session : Session;

    @:command public final breakpoints : Breakpoints;

    @:command public final stack : Stack;

    @:command public final step : Step;

    @:command public final locals : Locals;

    @:command public final eval : Eval;

    @:command public final threads : Threads;

    public function new(_session)
    {
        session = _session;

        breakpoints = new Breakpoints(session.breakpoints);
        stack       = new Stack(session.stack);
        step        = new Step(session);
        locals      = new Locals(session.locals);
        eval        = new Eval(session.eval, session.cache.stopReason);
        threads     = new Threads(session.threads);
    }

    @:command public function start(_prompt : tink.cli.Prompt)
    {
        return
            Promise
                .irreversible((_resolve, _reject) -> {
                    session.start(result -> {
                        switch result
                        {
                            case Success(run):
                                run(result -> {
                                    switch result
                                    {
                                        case Success(reason):
                                            _resolve(reason);
                                        case Error(exn):
                                            _reject(new Error(exn.message));
                                    }
                                });
                            case Error(exn):
                                _reject(new Error(exn.message));
                        }
                    });
                })
                .next(reason -> printStopReason(session, reason))
                .next(_prompt.println);
    }

    @:command public function resume(_prompt : tink.cli.Prompt)
    {
        return
            Promise
                .irreversible((_resolve, _reject) -> {
                    session.resume(result -> {
                        switch result
                        {
                            case Success(run):
                                run(result -> {
                                    switch result
                                    {
                                        case Success(reason):
                                            _resolve(reason);
                                        case Error(exn):
                                            _reject(new Error(exn.message));
                                    }
                                });
                            case Error(exn):
                                _reject(new Error(exn.message));
                        }
                    });
                })
                .next(reason -> printStopReason(session, reason))
                .next(_prompt.println);
    }

    @:command public function pause()
    {
        return Promise.irreversible((_resolve, _reject) -> {
            session.pause(result -> {
                switch result
                {
                    case Success(_):
                        _resolve((null : Noise));
                    case Error(exn):
                        _reject(new Error(exn.message));
                }
            });
        });
    }

    @:command public function exit()
    {
        shutdown();
    }

    @:defaultCommand public function help()
    {
        //
    }

    function shutdown()
    {
        Sys.exit(0);
    }
}