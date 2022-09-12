package hxcppdbg.dap.protocol.data;

typedef Variable = {
    final name : String;
    final value : String;
    final ?type : String;
    final ?presentationHint : VariablePresentationHint;
    final variablesReference : Int;
}