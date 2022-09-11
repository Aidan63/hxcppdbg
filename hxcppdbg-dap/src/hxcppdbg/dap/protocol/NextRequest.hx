package hxcppdbg.dap.protocol;

typedef NextRequest = {
    > Request,
    final arguments : NextArguments;
}

private typedef NextArguments = {
    final threadId : Int;
}