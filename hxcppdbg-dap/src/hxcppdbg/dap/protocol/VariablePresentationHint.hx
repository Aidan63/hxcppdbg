package hxcppdbg.dap.protocol;

typedef VariablePresentationHint = {
    final ?kind : String;
    final ?attributes : String;
    final ?visibility : String;
    final ?lazy : Bool;
}