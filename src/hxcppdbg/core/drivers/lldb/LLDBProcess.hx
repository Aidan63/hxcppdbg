package hxcppdbg.core.drivers.lldb;

@:keep
@:include('LLDBProcess.hpp')
@:native('hx::ObjectPtr<hxcppdbg::core::drivers::lldb::LLDBProcess>')
extern class LLDBProcess {
    function getState() : Int;

    function start(cwd : String) : Void;

    function resume() : Void;

    function dump() : Void;

    function getStackFrame(_threadIndex : Int, _frameIndex : Int) : Null<Frame>;

    function stepIn(_threadIndex : Int) : Frame;

    function stepOver(_threadIndex : Int) : Frame;

    function stepOut(_threadIndex : Int) : Frame;

    function getStackFrames(_threadIndex : Int) : Array<Frame>;

    function getStackVariables(_threadIndex : Int, _frameIndex : Int) : Array<Variable>;
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

@:keep
@:include('LLDBProcess.hpp')
@:native('hx::ObjectPtr<hxcppdbg::core::drivers::lldb::Variable>')
extern class Variable {
    final name : String;

    final value : String;

    final type : String;
}