package hxcppdbg;

function main()
{
    tink.Cli
        .process(Sys.args(), new Cli())
        .handle(tink.Cli.exit);
}