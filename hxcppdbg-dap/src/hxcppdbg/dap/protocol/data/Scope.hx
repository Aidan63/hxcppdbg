package hxcppdbg.dap.protocol.data;

typedef Scope = {
    final name : String;
    final ?presentationHint : String;
    final variablesReference : Int;
    final ?namedVariables : Int;
    final ?indexedVariables : Int;
    final expensive : Bool;
    final ?source : Source;
    final ?line : Int;
    final ?column : Int;
    final ?endLine : Int;
    final ?endColumn : Int;
}