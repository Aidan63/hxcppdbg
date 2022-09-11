package hxcppdbg.dap.protocol;

typedef PauseRequest = {
    > Request,
    final arguments : PauseArguments;
}

private typedef PauseArguments = {
    final threadId : Int;
}