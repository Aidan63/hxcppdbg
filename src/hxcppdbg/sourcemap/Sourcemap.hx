package hxcppdbg.sourcemap;

class Sourcemap {
    public var classes : Array<UserClass>;
}

class LineMapping {
    public var haxe : Int;

    public var cpp : Int;
}

class UserFunction {
    public var name : String;

    public var native : String;

    public var mapping : Array<LineMapping>;
}

class UserClass {
    @:alias('package')
    public var haxePackage : String;

    @:alias('native')
    public var cppPath : String;

    @:alias('functions')
    public var functions : Array<UserFunction>;
}