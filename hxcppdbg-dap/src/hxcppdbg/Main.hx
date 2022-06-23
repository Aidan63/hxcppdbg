package hxcppdbg;

function main()
{
    tink.Cli
        .process(Sys.args(), new hxcppdbg.dap.Dap())
        .handle(_ -> {});
}