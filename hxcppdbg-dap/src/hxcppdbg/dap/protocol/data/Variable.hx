package hxcppdbg.dap.protocol.data;

typedef Variable = {
    var name : String;
    var value : String;
    var variablesReference : Int;
    var ?type : String;
    var ?presentationHint : VariablePresentationHint;
    var ?namedVariables : Int;
    var ?indexedVariables : Int;
}