package hxcppdbg.core.drivers;

import hxcppdbg.core.stack.NativeFrame;

interface IStack
{
    function getCallStack(_thread : Int) : Array<NativeFrame>;
}