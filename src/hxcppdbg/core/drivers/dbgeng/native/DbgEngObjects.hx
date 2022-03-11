package hxcppdbg.core.drivers.dbgeng.native;

import haxe.ds.Option;
import hxcppdbg.core.ds.Result;
import hxcppdbg.core.locals.NativeLocal;
import hxcppdbg.core.drivers.dbgeng.utils.HResultException;

@:keep
@:include('DbgEngObjects.hpp')
@:native('hxcppdbg::core::drivers::dbgeng::native::DbgEngObjects')
@:buildXml('<include name="D:/programming/haxe/hxcppdbg/src/hxcppdbg/core/drivers/dbgeng/native/DbgEng.xml"/>')
extern class DbgEngObjects
{
    @:native('hxcppdbg::core::drivers::dbgeng::native::DbgEngObjects_obj::createFromFile')
    static function createFromFile(_file : String, _onBreakpointCb : Int->Int->Void) : Result<DbgEngObjects, HResultException>;

    function createBreakpoint(_file : String, _line : Int) : Result<Int, HResultException>;

    function removeBreakpoint(_breakpoint : Int) : Option<HResultException>;

    function getCallStack(_thread : Int) : Result<Array<NativeFrameReturn>, HResultException>;

    function getFrame(_thread : Int, _index : Int) : Result<NativeFrameReturn, HResultException>;

    function getVariables(_thread : Int, _frame : Int) : Result<Array<NativeLocal>, HResultException>;

    function getArguments(_thread : Int, _frame : Int) : Result<Array<NativeLocal>, HResultException>;

    function start(_status : Int) : Option<HResultException>;

    function step(_thread : Int, _status : Int) : Option<HResultException>;
}