package hxcppdbg;

import tink.cli.Prompt.PromptType;
import tink.cli.prompt.SysPrompt;

function main()
{
    tink.Cli
        .process(Sys.args(), new Frontend())
        .handle(tink.Cli.exit);
}