package hxcppdbg.dap.protocol;

typedef Breakpoint = {
    final ?id : Int;
    final verified : Bool;
    final ?message : String;
    final ?source : Source;
    final ?line : Int;
    final ?column : Int;
    final ?endLine : Int;
    final ?endColumn : Int;
}