package hxcppdbg.core.drivers.lldb;

@:keep
@:include('LLDBObjects.hpp')
@:native('hx::ObjectPtr<hxcppdbg::core::drivers::lldb::LLDBObjects>')
extern class LLDBObjects {
    @:native('hxcppdbg::core::drivers::lldb::LLDBObjects::createFromFile')
    static function createFromFile(file : String) : LLDBObjects;

    var onBreakpointHitCallback : (_breakpointID : Int, _threadIdx : Int)->Void;

    function launch() : LLDBProcess;

    function setBreakpoint(cppFile : String, cppLine : Int) : Null<Int>;

    function removeBreakpoint(id : Int) : Bool;
}