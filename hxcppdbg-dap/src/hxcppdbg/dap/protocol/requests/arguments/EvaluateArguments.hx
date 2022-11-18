package hxcppdbg.dap.protocol.requests.arguments;

import hxcppdbg.core.ds.FrameUID;
import hxcppdbg.dap.protocol.data.ValueFormat;

typedef EvaluateArguments = {
    final expression : String;
    final ?frameId : FrameUID;
    final ?context : String;
    final ?format : ValueFormat;
}