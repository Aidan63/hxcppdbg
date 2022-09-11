package hxcppdbg.dap.protocol;

typedef Variable = {
    final name : String;
    final value : String;
    final ?type : String;
    final ?presentationHint : VariablePresentationHint;
    final variablesReference : Int;
}