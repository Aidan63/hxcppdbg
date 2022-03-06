package hxcppdbg.core.drivers.lldb.native;

@:keep
@:include('LLDBObjects.hpp')
@:native('hx::ObjectPtr<hxcppdbg::core::drivers::lldb::native::LLDBObjects>')
extern class LLDBObjects
{
    @:native('hxcppdbg::core::drivers::lldb::native::LLDBObjects::createFromFile')
    static function createFromFile(file : String) : LLDBObjects;

    var onBreakpointHitCallback : (_breakpointID : Int, _threadIdx : Int)->Void;

    function launch() : LLDBProcess;

    function setBreakpoint(cppFile : String, cppLine : Int) : Null<Int>;

    function removeBreakpoint(id : Int) : Bool;
}