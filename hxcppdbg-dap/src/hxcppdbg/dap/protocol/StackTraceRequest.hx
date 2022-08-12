package hxcppdbg.dap.protocol;

typedef StackTraceRequest = {
    > Request,
    final arguments : StackTraceArguments;
}

private typedef StackTraceArguments = {
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