package hxcppdbg.core.drivers.lldb.native;

import haxe.Exception;
import haxe.ds.Option;
import hxcppdbg.core.ds.Result;

@:keep
@:include('LLDBObjects.hpp')
@:native('hxcppdbg::core::drivers::lldb::native::LLDBObjects')
extern class LLDBObjects
{
    @:native('hxcppdbg::core::drivers::lldb::native::LLDBObjects_obj::createFromFile')
    static function createFromFile(file : String) : Result<LLDBObjects, Exception>;

    function launch() : LLDBProcess;

    function setBreakpoint(cppFile : String, cppLine : Int) : Result<Int, Exception>;

    function removeBreakpoint(id : Int) : Option<Exception>;
}