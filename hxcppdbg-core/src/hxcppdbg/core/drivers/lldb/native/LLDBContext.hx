package hxcppdbg.core.drivers.lldb.native;

typedef LLDBFrame = {
    final path : String;
    final line : Int;
    final symbol : String;
}

@:keep
@:structAccess
@:include('LLDBContext.hpp')
@:native('hxcppdbg::core::drivers::lldb::native::LLDBContext')
extern class LLDBContext
{
    @:native('hxcppdbg::core::drivers::lldb::native::LLDBContext::create')
    static function create(_file : String, _onSuccess : cpp.Pointer<LLDBContext>->Void, _onFailure : String->Void) : Void;

    function start(_cwd : String) : Void;

    function resume() : Void;

    function wait(_onException : Int->Void, _onBreakpoint : (_threadIndex : Int, _breakpoint : haxe.Int64)->Void, _onInterrupt : Void->Void, _onBreak : Void->Void) : Void;

    function interrupt(_v : Int) : Void;

    function suspend() : Bool;

    function createBreakpoint(_file : String, _line : Int) : haxe.Int64;

    function removeBreakpoint(_id : haxe.Int64) : Bool;

    function getStackFrame(_threadIndex : Int, _frameIndex : Int) : LLDBFrame;

    function getStackFrames(_threadIndex : Int) : Array<LLDBFrame>;
}