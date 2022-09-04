package hxcppdbg.core.drivers.lldb.native;

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

    function wait(_onException : Int->Void, _onBreakpoint : Int->Void, _onInterrupt : Void->Void, _onBreak : Void->Void) : Void;

    function interrupt(_v : Int) : Void;

    function suspend(_onSuccess : Void->Void, _onFailure : String->Void) : Bool;
}