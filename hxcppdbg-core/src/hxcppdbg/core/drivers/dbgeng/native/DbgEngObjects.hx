package hxcppdbg.core.drivers.dbgeng.native;

import haxe.ds.Option;
import hxcppdbg.core.ds.Result;
import hxcppdbg.core.model.Model;
import hxcppdbg.core.locals.NativeLocal;
import hxcppdbg.core.drivers.dbgeng.utils.HResultException;
import hxcppdbg.core.sourcemap.Sourcemap.GeneratedType;

enum InterruptReason
{
    Breakpoint;
    Exception;
    Unknown;
    Pause;
}

enum WaitResult
{
    Complete;
    WaitFailed;
    Interrupted(reason : InterruptReason);
}

@:keep
@:include('DbgEngObjects.hpp')
@:native('hxcppdbg::core::drivers::dbgeng::native::DbgEngObjects_obj')
#if !display
@:build(hxcppdbg.core.utils.HxcppUtils.xml('DbgEng'))
#end
extern class DbgEngObjects
{
    @:native('new hxcppdbg::core::drivers::dbgeng::native::DbgEngObjects_obj')
    static function alloc() : cpp.Pointer<DbgEngObjects>;

    function createFromFile(_file : String, _enums : Array<GeneratedType>, _classes : Array<GeneratedType>) : Option<HResultException>;

    function createBreakpoint(_file : String, _line : Int) : Result<Int, HResultException>;

    function removeBreakpoint(_breakpoint : Int) : Option<HResultException>;

    function getCallStack(_thread : Int) : Result<Array<NativeFrameReturn>, HResultException>;

    function getFrame(_thread : Int, _index : Int) : Result<NativeFrameReturn, HResultException>;

    function getVariables(_thread : Int, _frame : Int) : Result<Array<Model>, HResultException>;

    function getArguments(_thread : Int, _frame : Int) : Result<Array<NativeLocal>, HResultException>;

    function go() : Option<HResultException>;

    function step(_thread : Int, _status : Int) : Option<HResultException>;

    function pause() : Option<HResultException>;

    function end() : Option<HResultException>;

    function interrupt() : Result<Int, HResultException>;

    function wait() : WaitResult;
}