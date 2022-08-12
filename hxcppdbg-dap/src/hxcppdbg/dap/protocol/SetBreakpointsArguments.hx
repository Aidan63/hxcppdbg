package hxcppdbg.dap.protocol;

typedef SetBreakpointsArguments = {
    final source : Source;
    final breakpoints : Array<SourceBreakpoint>;
    final ?sourceModified : Bool;
}