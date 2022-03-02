package hxcppdbg.core.drivers.dbgeng.native;

@:keep
@:include('DbgEngObjects.hpp')
@:native('hx::ObjectPtr<hxcppdbg::core::drivers::dbgeng::native::DbgEngObjects>')
@:buildXml('<include name="D:/programming/haxe/hxcppdbg/src/hxcppdbg/core/drivers/dbgeng/native/DbgEng.xml"/>')
extern class DbgEngObjects
{
    @:native('hxcppdbg::core::drivers::dbgeng::native::DbgEngObjects::createFromFile')
    static function createFromFile(_file : String, _onBreakpointCb : Int->Int->Void) : DbgEngObjects;

    function createBreakpoint(_file : String, _line : Int) : Null<Int>;

    function getCallStack(_thread : Int) : Array<RawStackFrame>;

    function getFrame(_thread : Int, _index : Int) : RawStackFrame;

    function start(_status : Int) : Void;

    function step(_thread : Int, _status : Int) : Void;
}