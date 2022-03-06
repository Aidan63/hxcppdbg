package hxcppdbg.core.drivers.lldb.native;

@:keep
@:include('LLDBProcess.hpp')
@:native('hx::ObjectPtr<hxcppdbg::core::drivers::lldb::native::LLDBProcess>')
extern class LLDBProcess {
    function getState() : Int;

    function start(cwd : String) : Void;

    function resume() : Void;

    function dump() : Void;

    function getStackFrame(_threadIndex : Int, _frameIndex : Int) : Null<RawStackFrame>;

    function stepIn(_threadIndex : Int) : RawStackFrame;

    function stepOver(_threadIndex : Int) : RawStackFrame;

    function stepOut(_threadIndex : Int) : RawStackFrame;

    function getStackFrames(_threadIndex : Int) : Array<RawStackFrame>;

    function getStackVariables(_threadIndex : Int, _frameIndex : Int) : Array<RawStackLocal>;
}