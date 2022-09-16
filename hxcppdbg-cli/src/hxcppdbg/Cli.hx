package hxcppdbg;

import sys.FileSystem;
import tink.CoreApi.Noise;
import tink.CoreApi.Error;
import tink.CoreApi.Promise;
import tink.cli.Prompt.PromptType;
import hxcppdbg.cli.Hxcppdbg;
import hxcppdbg.core.Session;

using Lambda;
using haxe.EnumTools;

class Cli
{
    final regex : EReg;

    public var target : String;

    public var sourcemap : String;

    public function new()
    {
        regex = ~/\s+/g;
    }

    @:defaultCommand public function run()
    {
        return Promise.irreversible((_ : Noise->Void, _reject : Error->Void) -> {
            cpp.asio.Signal.open(result -> {
                switch result
                {
                    case Success(signal):
                        Session.create(
                            FileSystem.absolutePath(target),
                            FileSystem.absolutePath(sourcemap), 
                            result -> {
                                switch result
                                {
                                    case Success(session):
                                        signal.start(Interrupt, result -> {
                                            switch result
                                            {
                                                case Success(data):
                                                    new Hxcppdbg(session).pause();
                                                case Error(error):
                                                    _reject(new Error(error.toString()));
                                            }
                                        });
                
                                        cpp.asio.TTY.open(Stdout, result -> {
                                            switch result
                                            {
                                                case Success(stdout):
                                                    cpp.asio.TTY.open(Stdin, result -> {
                                                        switch result
                                                        {
                                                            case Success(stdin):
                                                                waitForInput(new AsioPrompt(stdin.read, stdout.write), session, _reject);
                                                            case Error(error):
                                                                _reject(new Error(error.toString()));
                                                        }
                                                    });
                                                case Error(error):
                                                    _reject(new Error(error.toString()));
                                            }
                                        });
                                    case Error(exn):
                                        _reject(new Error(exn.message));
                                }
                            });
                    case Error(error):
                        _reject(new Error(error.toString()));
                }
            });
        });
    }

    @:command public function help()
    {
        //
    }

    function waitForInput(_prompt : AsioPrompt, _session : Session, _reject : Error->Void)
    {
        _prompt
            .prompt(PromptType.ofString('hxcppdbg'))
            .handle(outcome -> {
                switch outcome
                {
                    case Success(result):
                        tink.Cli
                            .process(regex.split(result), new Hxcppdbg(_session), _prompt)
                            .handle(outcome -> {
                                switch outcome
                                {
                                    case Success(_):
                                        //
                                    case Failure(error):
                                        _prompt
                                            .println(error.message)
                                            .handle(_ -> {});
                                }

                                waitForInput(_prompt, _session, _reject);
                            });
                    case Failure(error):
                        _reject(error);
                }
            });
    }
}