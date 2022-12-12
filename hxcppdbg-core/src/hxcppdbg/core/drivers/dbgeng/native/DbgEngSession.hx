package hxcppdbg.core.drivers.dbgeng.native;

import haxe.Int64;
import hxcppdbg.core.drivers.dbgeng.native.models.IDbgEngKeyable;
import hxcppdbg.core.drivers.dbgeng.native.NativeModelData.NamedNativeModelData;

typedef DbgEngFrame = {
    final file : String;
    final func : String;
    final line : Int;
    final address : cpp.UInt64;
}

@:native('hxcppdbg::core::drivers::dbgeng::native::DbgEngSession')
@:include('DbgEngSession.hpp')
@:structAccess
extern class DbgEngSession
{
    function createBreakpoint(_file : String, _line : Int) : Int64;

    function removeBreakpoint(_breakpoint : Int64) : Void;

    function getThreads() : Array<Int>;

    function getCallStack(_thread : Int) : Array<DbgEngFrame>;

    function getFrame(_thread : Int, _index : Int) : DbgEngFrame;

    function getVariables(_thread : Int, _frame : Int) : cpp.Pointer<IDbgEngKeyable<String, NamedNativeModelData>>;

    function getArguments(_thread : Int, _frame : Int) : cpp.Pointer<IDbgEngKeyable<String, NamedNativeModelData>>;

    function go() : Void;

    function step(_thread : Int, _status : Int) : Void;

    function end() : Void;

    function interrupt() : Bool;

    function wait(
        _onBreakpoint : Int->Int->Void,
        _onException : Int->Int->Null<NativeModelData>->Void,
        _onPaused : Void->Void,
        _onExited : Int->Void,
        _onThreadCreated : Int->Void,
        _onThreadExited : Int->Void
    ) : Void;
}