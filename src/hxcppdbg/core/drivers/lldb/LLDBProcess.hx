package hxcppdbg.core.drivers.lldb;

@:keep
@:include('LLDBProcess.hpp')
@:native('hx::ObjectPtr<hxcppdbg::core::drivers::lldb::LLDBProcess>')
extern class LLDBProcess {
    function getState() : Int;

    function start(cwd : String) : Void;

    function resume() : Void;

    function dump() : Void;

    function getStackFrames(_threadID : Int) : Array<Frame>;
}

@:keep
@:include('LLDBProcess.hpp')
@:native('hx::ObjectPtr<hxcppdbg::core::drivers::lldb::Frame>')
extern class Frame {
    final file : String;

    final func : String;

    final symbol : String;

    final line : Int;
}