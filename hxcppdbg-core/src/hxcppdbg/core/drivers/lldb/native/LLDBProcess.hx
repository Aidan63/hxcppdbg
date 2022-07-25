package hxcppdbg.core.drivers.lldb.native;

import hxcppdbg.core.model.Model;
import haxe.ds.Option;
import haxe.Exception;
import hxcppdbg.core.ds.Result;
import hxcppdbg.core.stack.NativeFrame;
import hxcppdbg.core.locals.NativeLocal;

@:keep
@:include('LLDBProcess.hpp')
@:native('hxcppdbg::core::drivers::lldb::native::LLDBProcess')
extern class LLDBProcess
{
    function getState() : Int;

    function start(cwd : String) : Result<StopReason, Exception>;

    function resume() : Result<StopReason, Exception>;

    function pause() : Option<Exception>;

    function stepIn(_threadIndex : Int) : Result<StopReason, Exception>;

    function stepOver(_threadIndex : Int) : Result<StopReason, Exception>;

    function stepOut(_threadIndex : Int) : Result<StopReason, Exception>;

    function getStackFrame(_threadIndex : Int, _frameIndex : Int) : Result<NativeFrame, Exception>;

    function getStackFrames(_threadIndex : Int) : Result<Array<NativeFrame>, Exception>;

    function getStackVariables(_threadIndex : Int, _frameIndex : Int) : Result<Array<Model>, Exception>;
}