package hxcppdbg.core.sourcemap;

using Lambda;

@:structInit class Sourcemap
{
    public final files : Array<GeneratedFile>;

    public final classes : Array<GeneratedClass>;

    public final enums : Array<GeneratedEnum>;

    public function cppEnumNames()
    {
        return enums.map(e -> e.name.cpp);
    }

    public function cppClassNames()
    {
        return classes.map(c -> c.name.cpp);
    }
}

@:structInit class GeneratedFile
{
    public final cpp : String;

    public final haxe : String;

    public final type : String;

    public final functions : Array<Function>;
}

@:structInit class GeneratedClass
{
    public final name : NameMap;

    public final fields : Array<NameMap>;
}

@:structInit class GeneratedEnum
{
    public final name : NameMap;

    public final constructors : Array<NameMap>;
}

@:structInit class Closure
{
    public final name : String;

    public final arguments : Array<NameMap>;

    public final exprs : Array<ExprMap>;
}

@:structInit class Function
{
    public final name : String;

    public final cpp : String;

    public final arguments : Array<NameMap>;

    public final variables : Array<NameMap>;

    public final closures : Array<Closure>;

    public final exprs : Array<ExprMap>;
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