package hxcppdbg.dap.protocol;

typedef VariablesRequest = {
    > Request,
    final arguments : VariablesArguments;
}

private typedef VariablesArguments = {
    final variablesReference : Int;
}