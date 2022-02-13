package hxcppdbg.core.drivers.lldb;

@:keep
@:include('LLDBObjects.hpp')
@:native('hx::ObjectPtr<hxcppdbg::core::drivers::lldb::LLDBObjects>')
extern class LLDBObjects {
    @:native('hxcppdbg::core::drivers::lldb::LLDBObjects::createFromFile')
    static function createFromFile(file : String) : LLDBObjects;

    function launch(cwd : String) : LLDBProcess;
}