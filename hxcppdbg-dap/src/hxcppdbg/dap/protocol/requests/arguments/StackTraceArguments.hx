package hxcppdbg.dap.protocol.requests.arguments;

import hxcppdbg.dap.protocol.data.ValueFormat;

typedef StackTraceArguments = {
    final threadId : Int;
    final ?startFrame : Int;
    final ?levels : Int;
    final ?format : StackFrameFormat;
}

private typedef StackFrameFormat = {
    > ValueFormat,
    final ?parameters : Bool;
    final ?parameterTypes : Bool;
    final ?parameterNames : Bool;
    final ?parameterValues : Bool;
    final ?line : Bool;
    final ?module : Bool;
    final ?includeAll : Bool;
}