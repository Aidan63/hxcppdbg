package hxcppdbg.cli;

import tink.cli.Prompt.PromptType;
import tink.cli.prompt.SysPrompt;

function main()
{
    tink.Cli
        .process(Sys.args(), new Frontend())
        .handle(tink.Cli.exit);
// #if HX_WINDOWS
//     final sourcemap = new json2object.JsonParser<Sourcemap>().fromJson(File.getContent('D:/programming/haxe/hxcppdbg/sample/sourcemap.json'));
//     final driver    = new hxcppdbg.core.drivers.dbgeng.DbgEngDriver('D:/programming/haxe/hxcppdbg/sample/bin/windows/Main-debug.exe');
// #else
//     final sourcemap = new json2object.JsonParser<Sourcemap>().fromJson(File.getContent('/mnt/d/programming/haxe/hxcppdbg/sample_sourcemap.json'));
//     final driver    = new hxcppdbg.core.drivers.lldb.LLDBDriver('/mnt/d/programming/haxe/hxcppdbg/sample/bin/Main-debug');
// #end
//     final thread    = Thread.createWithEventLoop(tick);
//     final event     = thread.events.repeat(tick, 0);
//     final session   = new DebugSession(driver, sourcemap);
//     final regex     = ~/\s+/g;
//     final input     = new SysPrompt();

//     while (true)
//     {
//         input
//             .prompt(PromptType.ofString('hxcppdbg '))
//             .handle(cb -> {
//                 switch cb
//                 {
//                     case Success(data):
//                         final args = regex.split(data);
        
//                         tink.Cli
//                             .process(args, new Hxcppdbg(thread, event, session))
//                             .handle(_ -> {});
//                     case Failure(failure):
//                         failure.throwSelf();
//                 }
//             });
//     }
}