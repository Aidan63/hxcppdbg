package hxcppdbg.core.drivers;

import haxe.Exception;
import hxcppdbg.core.ds.Result;
import hxcppdbg.core.stack.NativeFrame;

interface IStack
{
    function getCallStack(_thread : Int, _result : Result<Array<NativeFrame>, Exception>->Void) : Void;

    function getFrame(_thread : Int, _index : Int, _result : Result<NativeFrame, Exception>->Void) : Void;
}