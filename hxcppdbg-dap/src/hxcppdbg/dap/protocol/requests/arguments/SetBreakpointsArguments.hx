package hxcppdbg.dap.protocol.requests.arguments;

import hxcppdbg.dap.protocol.data.Source;
import hxcppdbg.dap.protocol.data.SourceBreakpoint;

typedef SetBreakpointsArguments = {
    final source : Source;
    final breakpoints : Array<SourceBreakpoint>;
    final ?sourceModified : Bool;
}