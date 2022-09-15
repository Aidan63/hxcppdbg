package hxcppdbg.dap.protocol.requests.arguments;

import hxcppdbg.dap.protocol.data.ValueFormat;

typedef EvaluateArguments = {
    final expression : String;
    final ?frameId : FrameId;
    final ?context : String;
    final ?format : ValueFormat;
}