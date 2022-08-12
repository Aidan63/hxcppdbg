package hxcppdbg.dap.protocol;

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

enum abstract StackFramePresentationHint(String)
{
    final Normal = 'normal';
    final Label = 'label';
    final Subtle = 'subtle';
}