package hxcppdbg.core.drivers.lldb.native;

typedef LLDBFrame = {
    final path : String;
    final line : Int;
    final symbol : String;
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
    static function create(_file : String) : cpp.Pointer<LLDBContext>;

    function start(_cwd : String) : Void;

    function resume() : Void;

    function wait(_onException : Int->Void, _onBreakpoint : (_threadIndex : Int, _breakpoint : haxe.Int64)->Void, _onInterrupt : Void->Void, _onBreak : Void->Void) : Void;

    function interrupt(_v : Int) : Void;

    function suspend() : Bool;

    function createBreakpoint(_file : String, _line : Int) : haxe.Int64;

    function removeBreakpoint(_id : haxe.Int64) : Bool;

    function getStackFrame(_threadIndex : Int, _frameIndex : Int) : LLDBFrame;

    function getStackFrames(_threadIndex : Int) : Array<LLDBFrame>;

    function step(_threadIndex : Int, _step : LLDBStepType) : Void;
}