package hxcppdbg.cli;

import sys.io.File;
import hxcppdbg.core.DebugSession;
import hxcppdbg.core.drivers.lldb.LLDBDriver;
import hxcppdbg.core.sourcemap.Sourcemap;
import sys.thread.Thread;
import tink.cli.Prompt.PromptType;
import tink.cli.prompt.SysPrompt;

function main() {
    final sourcemap = new json2object.JsonParser<Sourcemap>().fromJson(File.getContent('/mnt/d/programming/haxe/hxcppdbg/sample_sourcemap.json'));
    final driver    = new LLDBDriver('/mnt/d/programming/haxe/hxcppdbg/sample/bin/Main-debug');
    final thread    = Thread.createWithEventLoop(tick);
    final event     = thread.events.repeat(tick, 0);
    final session   = new DebugSession(driver, sourcemap);
    final regex     = ~/\s+/g;
    final input     = new SysPrompt();

    while (true) {
        input
            .prompt(PromptType.ofString('hxcppdbg '))
            .handle(cb -> {
                switch cb {
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

function tick() {
    Sys.sleep(1 / 1000);
}
