package hxcppdbg.core.sourcemap;

@:structInit class Sourcemap
{
    public var files : Array<GeneratedFile>;
}

@:structInit class GeneratedFile
{
    public var cpp : String;

    public var haxe : String;

    public var type : String;

    public var functions : Array<Function>;

    public var exprs : Array<ExprMap>;
}

@:structInit class Closure
{
    public var name : String;

    public var arguments : Array<NameMap>;
}

@:structInit class Function
{
    public var name : String;

    public var cpp : String;

    public var arguments : Array<NameMap>;

    public var variables : Array<NameMap>;

    public var closures : Array<Closure>;
}

@:structInit class ExprMap
{
    public var haxe : ExprRange;

    public var cpp : Int;
}

@:structInit class ExprRange
{
    public var start : Position;

    public var end : Position;
}

@:structInit class NameMap
{
    public var haxe : String;

    public var cpp : String;

    public var type : String;
}

@:structInit class Position
{
    public var line : Int;

    public var col : Int;
}