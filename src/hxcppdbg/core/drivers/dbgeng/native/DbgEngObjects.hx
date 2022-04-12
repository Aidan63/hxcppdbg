package hxcppdbg.core.drivers.dbgeng.native;

import haxe.ds.Option;
import hxcppdbg.core.ds.Result;
import hxcppdbg.core.model.Model;
import hxcppdbg.core.locals.NativeLocal;
import hxcppdbg.core.drivers.dbgeng.utils.HResultException;

@:keep
@:include('DbgEngObjects.hpp')
@:native('hxcppdbg::core::drivers::dbgeng::native::DbgEngObjects')
@:build(hxcppdbg.core.utils.HxcppUtils.xml('DbgEng'))
extern class DbgEngObjects
{
    @:native('hxcppdbg::core::drivers::dbgeng::native::DbgEngObjects_obj::createFromFile')
    static function createFromFile(_file : String) : Result<DbgEngObjects, HResultException>;

    function createBreakpoint(_file : String, _line : Int) : Result<Int, HResultException>;

    function removeBreakpoint(_breakpoint : Int) : Option<HResultException>;

    function getCallStack(_thread : Int) : Result<Array<NativeFrameReturn>, HResultException>;

    function getFrame(_thread : Int, _index : Int) : Result<NativeFrameReturn, HResultException>;

    function getVariables(_thread : Int, _frame : Int) : Result<Array<Model>, HResultException>;

    function getArguments(_thread : Int, _frame : Int) : Result<Array<NativeLocal>, HResultException>;

    function start(_status : Int) : Result<StopReason, HResultException>;

    function step(_thread : Int, _status : Int) : Result<StopReason, HResultException>;
}