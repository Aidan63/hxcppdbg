package hxcppdbg.dap.protocol.requests.arguments;

typedef VariablesArguments = {
    final variablesReference : Int;
    final ?filter : String;
    final ?start : Int;
    final ?count : Int;
}