package hxcppdbg.core.sourcemap;

class Sourcemap {
    public var files : Array<GeneratedFile>;
}

class GeneratedFile {
    public var generated : String;

    public var haxe : String;

    public var type : String;

    public var closures : Array<Closure>;

    public var functions : Array<Function>;

    public var exprs : Array<ExprMap>;
}

class Closure {
    public var name : String;

    public var captures : Array<NameMap>;
}

class Function {
    public var haxe : String;

    public var cpp : String;

    public var arguments : Array<NameMap>;

    public var variables : Array<NameMap>;
}

class ExprMap {
    public var haxe : ExprRange;

    public var cpp : ExprRange;
}

class ExprRange {
    public var start : Position;

    public var end : Position;
}

class NameMap {
    public var haxe : String;

    public var cpp : String;

    public var type : String;
}

class Position {
    public var line : Int;

    public var col : Int;
}