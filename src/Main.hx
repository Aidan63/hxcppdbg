import tink.cli.Prompt.PromptType;
import hxcppdbg.Hxcppdbg;
import sys.thread.Thread;
import tink.cli.prompt.SysPrompt;

function main() {
    final thread = Thread.createWithEventLoop(tick);
    final event  = thread.events.repeat(tick, 0);
    final hxcpp  = new Hxcppdbg(thread, event);
    final regex  = ~/\s+/g;
    final input  = new SysPrompt();

    while (true) {
        input
            .prompt(PromptType.ofString('hxcppdbg '))
            .handle(cb -> {
                switch cb {
                    case Success(data):
                        final args = regex.split(data);
        
                        tink.Cli
                            .process(args, hxcpp)
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
