package hxcppdbg.core.drivers.dbgeng.native;

import hxcppdbg.core.ds.Result;
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

    function getCallStack(_thread : Int) : Array<RawStackFrame>;

    function getFrame(_thread : Int, _index : Int) : RawStackFrame;

    function getVariables(_thread : Int, _frame : Int) : Array<RawFrameLocal>;

    function getArguments(_thread : Int, _frame : Int) : Array<RawFrameLocal>;

    function start(_status : Int) : Void;

    function step(_thread : Int, _status : Int) : Void;
}