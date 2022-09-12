package hxcppdbg.dap.protocol.data;

typedef SourceBreakpoint = {
    final line : Int;
    final ?column : Int;
    final ?condition : String;
    final ?hitCondition : String;
    final ?logMessage : String;
}