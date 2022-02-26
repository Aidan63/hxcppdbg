package hxcppdbg.core.drivers.dbgeng.native;

@:keep
@:include('DbgEngObjects.hpp')
@:native('hx::ObjectPtr<hxcppdbg::core::drivers::dbgeng::native::DbgEngObjects>')
@:buildXml('<include name="D:/programming/haxe/hxcppdbg/src/hxcppdbg/core/drivers/dbgeng/native/DbgEng.xml"/>')
extern class DbgEngObjects
{
    @:native('hxcppdbg::core::drivers::dbgeng::native::DbgEngObjects::createFromFile')
    static function createFromFile(_file : String) : DbgEngObjects;

    function createBreakpoint(_file : String, _line : Int) : Null<Int>;

    function start() : Void;
}