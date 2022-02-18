package hxcppdbg.core.stack;

import haxe.ds.Either;
import hxcppdbg.core.sourcemap.Sourcemap;

class ClosureDefinition {
    public final definition : Closure;

    public final caller : String;

    public function new(_definition, _caller) {
        definition = _definition;
        caller     = _caller;
    }
}

enum StackFrame {
    Haxe(file : GeneratedFile, type : Either<Function, ClosureDefinition>, line : Int);
    Native(file : String, type : String, line : Int);
}