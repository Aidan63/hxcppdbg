package hxcppdbg.core.drivers.dbgeng.native;

import haxe.ds.Option;
import hxcppdbg.core.ds.Result;
import hxcppdbg.core.model.Model;
import hxcppdbg.core.locals.NativeLocal;
import hxcppdbg.core.drivers.dbgeng.utils.HResultException;
import hxcppdbg.core.sourcemap.Sourcemap.GeneratedType;

enum InterruptReason
{
    Breakpoint(threadIdx : Option<Int>, id : Option<Int>);
    Exception(threadIdx : Option<Int>, code : Option<Int>);
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
@:include('DbgEngContext.hpp')
@:native('hxcppdbg::core::drivers::dbgeng::native::DbgEngContext')
#if !display
@:build(hxcppdbg.core.utils.HxcppUtils.xml('DbgEng'))
#end
extern class DbgEngContext
{
    @:native('new hxcppdbg::core::drivers::dbgeng::native::DbgEngContext')
    static function alloc() : cpp.Pointer<DbgEngContext>;

    function createFromFile(_file : String, _enums : Array<GeneratedType>, _classes : Array<GeneratedType>) : Option<HResultException>;

    function createBreakpoint(_file : String, _line : Int) : Result<Int, HResultException>;

    function removeBreakpoint(_breakpoint : Int) : Option<HResultException>;

    function getThreads() : Result<Array<NativeThreadReturn>, HResultException>;

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