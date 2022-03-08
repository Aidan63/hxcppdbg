package hxcppdbg.core.drivers;

import haxe.Exception;
import hxcppdbg.core.ds.Result;
import hxcppdbg.core.stack.NativeFrame;

interface IStack
{
    function getCallStack(_thread : Int) : Result<Array<NativeFrame>, Exception>;

    function getFrame(_thread : Int, _index : Int) : Result<NativeFrame, Exception>;
}