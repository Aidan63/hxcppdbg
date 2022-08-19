package hxcppdbg.dap.protocol;

typedef ScopesRequest = {
    > Request,
    final arguments : ScopeArguments;
}

private typedef ScopeArguments = {
    final frameId : Int;
}