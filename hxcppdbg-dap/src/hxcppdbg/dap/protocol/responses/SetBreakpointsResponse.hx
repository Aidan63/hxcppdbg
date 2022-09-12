package hxcppdbg.dap.protocol.responses;

import hxcppdbg.dap.protocol.data.Breakpoint;

typedef SetBreakpointsResponse = {
    final breakpoints : Array<Breakpoint>;
}