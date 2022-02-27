package hxcppdbg.cli;

import sys.FileSystem;
import sys.thread.Thread;
import tink.cli.Prompt.PromptType;
import tink.cli.prompt.SysPrompt;
import hxcppdbg.core.Session;

enum abstract Mode(String)
{
    var cli;
    var dap;
}

class Frontend
{
    @:command public var cli : Cli;

    @:command public var dap : Dap;
    
    public function new()
    {
        cli = new Cli();
    }

    @:defaultCommand public function help()
    {
        //
    }
}

class Cli
{
    public var target : String;

    public var sourcemap : String;

    public function new()
    {
        //
    }

    @:defaultCommand public function run()
    {
        final thread  = Thread.createWithEventLoop(tick);
        final event   = thread.events.repeat(tick, 0);
        final session = new Session(FileSystem.absolutePath(target), FileSystem.absolutePath(sourcemap));
        final regex   = ~/\s+/g;
        final input   = new SysPrompt();

        while (true)
        {
            input
                .prompt(PromptType.ofString('hxcppdbg '))
                .handle(cb -> {
                    switch cb
                    {
                        case Success(data):
                            final args = regex.split(data);
            
                            tink.Cli
                                .process(args, new Hxcppdbg(thread, event, session))
                                .handle(_ -> {});
                        case Failure(failure):
                            failure.throwSelf();
                    }
                });
        }
    }

    @:command public function help()
    {
        //
    }

    function tick()
    {
        Sys.sleep(1 / 1000);
    }        
}

class Dap
{
    public function new()
    {
        //
    }

    @:defaultCommand public function help()
    {
        //
    }
}
