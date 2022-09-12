package hxcppdbg.dap.protocol.responses;

import hxcppdbg.dap.protocol.data.StackFrame;

typedef StackTraceResponse = {
    final stackFrames : Array<StackFrame>;
    final ?totalFrames : Int;
}