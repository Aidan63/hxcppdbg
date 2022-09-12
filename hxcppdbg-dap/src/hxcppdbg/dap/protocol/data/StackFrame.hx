package hxcppdbg.dap.protocol.data;

typedef StackFrame = {
    final id : Int;
    final name : String;
    final ?source : Source;
    final line : Int;
    final column : Int;
    final ?endLine : Int;
    final ?endColumn : Int;
    final ?presentationHint : StackFramePresentationHint;
    final ?sources : Array<Source>;
}