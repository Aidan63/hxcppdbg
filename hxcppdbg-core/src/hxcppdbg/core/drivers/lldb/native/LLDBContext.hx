package hxcppdbg.core.drivers.lldb.native;

typedef LLDBFrame = {
    final path : String;
    final line : Int;
    final symbol : String;
}

typedef LLDBThread = {
    final index : Int;
    final name : String;
}

typedef LLDBLocal = {
    final name : String;
    final type : String;
}

enum abstract LLDBStepType(Int)
{
    var In;
    var Over;
    var Out;
}

@:keep
@:unreflective
@:structAccess
@:include('LLDBContext.hpp')
@:native('hxcppdbg::core::drivers::lldb::native::LLDBContext')
@:build(hxcppdbg.core.utils.HxcppUtils.xml('LLDB'))
extern class LLDBContext
{
    @:native('hxcppdbg::core::drivers::lldb::native::LLDBContext::boot')
    static function boot() : Void;

    @:native('hxcppdbg::core::drivers::lldb::native::LLDBContext::create')
    static function create(_cwd : String, _file : String) : cpp.Pointer<LLDBContext>;

    function start() : Void;

    function resume() : Void;

    function wait(_onException : Int->Void, _onBreakpoint : Int->haxe.Int64->Void, _onPaused : Void->Void, _onExited : haxe.Int64->Void) : Void;

    function interrupt(_v : Int) : Bool;

    function createBreakpoint(_file : String, _line : Int) : haxe.Int64;

    function removeBreakpoint(_id : haxe.Int64) : Bool;

    function getStackFrame(_threadIndex : Int, _frameIndex : Int) : LLDBFrame;

    function getStackFrames(_threadIndex : Int) : Array<LLDBFrame>;

    function getThreads() : Array<LLDBThread>;

    function getLocals(_threadIndex : Int, _threadFrame : Int) : Array<LLDBLocal>;

    function getArguments(_threadIndex : Int, _threadFrame : Int) : Array<LLDBLocal>;

    function step(_threadIndex : Int, _step : LLDBStepType) : Void;
}