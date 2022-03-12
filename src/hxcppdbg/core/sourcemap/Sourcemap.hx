package hxcppdbg.core.sourcemap;

@:structInit class Sourcemap
{
    public final files : Array<GeneratedFile>;
}

@:structInit class GeneratedFile
{
    public final cpp : String;

    public final haxe : String;

    public final type : String;

    public final functions : Array<Function>;

    public final exprs : Array<ExprMap>;
}

@:structInit class Closure
{
    public final name : String;

    public final arguments : Array<NameMap>;
}

@:structInit class Function
{
    public final name : String;

    public final cpp : String;

    public final arguments : Array<NameMap>;

    public final variables : Array<NameMap>;

    public final closures : Array<Closure>;
}

@:structInit class ExprMap
{
    public final haxe : ExprRange;

    public final cpp : Int;
}

@:structInit class ExprRange
{
    public final start : Position;

    public final end : Position;
}

@:structInit class NameMap
{
    public final haxe : String;

    public final cpp : String;

    public final type : String;
}

@:structInit class Position
{
    public final line : Int;

    public final col : Int;
}