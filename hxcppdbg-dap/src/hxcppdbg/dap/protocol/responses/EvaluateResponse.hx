package hxcppdbg.dap.protocol.responses;

import hxcppdbg.dap.protocol.data.VariablePresentationHint;

typedef EvaluateResponse = {
    final result : String;
    final ?type : String;
    final ?presentationHint : VariablePresentationHint;
    final variablesReference : Int;
    final ?namedVariables : Int;
    final ?indexedVariables : Int;
    final ?memoryReference : String;
}