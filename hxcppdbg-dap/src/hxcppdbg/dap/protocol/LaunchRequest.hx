package hxcppdbg.dap.protocol;

typedef LaunchRequest = {
    > Request,
    final arguments : LaunchRequestArguments;
}

private typedef LaunchRequestArguments = {
    final program : String;
    final sourcemap : String;
}