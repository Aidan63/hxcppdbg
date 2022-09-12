package hxcppdbg.dap.protocol.data;

typedef VariablePresentationHint = {
    final ?kind : String;
    final ?attributes : String;
    final ?visibility : String;
    final ?lazy : Bool;
}