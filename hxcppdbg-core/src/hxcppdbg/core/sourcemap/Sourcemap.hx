package hxcppdbg.core.sourcemap;

import hxcppdbg.core.ds.Path;
import hxjsonast.Json;

using Lambda;

@:structInit class Sourcemap
{
    public final files : Array<GeneratedFile>;

    public final classes : Array<GeneratedClass>;

    public final enums : Array<GeneratedEnum>;
}

@:structInit class GeneratedFile
{
    @:jcustomparse(hxcppdbg.core.sourcemap.Sourcemap.GeneratedFile.parsePath)
    public final cpp : Path;

    @:jcustomparse(hxcppdbg.core.sourcemap.Sourcemap.GeneratedFile.parsePath)
    public final haxe : Path;

    public final type : String;

    public final functions : Array<Function>;

    public static function parsePath(_val : Json, _name : String) : Path
    {
        return switch _val.value
        {
            case JString(s):
                Path.of(s);
            case _:
                null;
        }
    }
}

@:structInit class GeneratedType
{
    public final pack : Array<String>;

    public final module : String;

    public final name : String;

    public final cpp : String;
}

@:structInit class GeneratedClass
{
    public final type : GeneratedType;

    public final fields : Array<NameMap>;
}

@:structInit class GeneratedEnum
{
    public final type : GeneratedType;

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