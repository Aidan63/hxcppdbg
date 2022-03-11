package hxcppdbg.core.drivers.dbgeng;

import haxe.Exception;
import hxcppdbg.core.ds.Result;
import hxcppdbg.core.stack.NativeFrame;
import hxcppdbg.core.drivers.dbgeng.native.DbgEngObjects;

using Lambda;
using StringTools;
using hxcppdbg.core.utils.ResultUtils;

class DbgEngStack implements IStack
{
    final objects : DbgEngObjects;
    
	public function new(_objects)
    {
        objects = _objects;
	}

    public function getCallStack(_thread : Int) : Result<Array<NativeFrame>, Exception>
    {
        return objects.getCallStack(_thread).map(item -> item.frame).asExceptionResult();
    }

    public function getFrame(_thread : Int, _index : Int) : Result<NativeFrame, Exception>
    {
        return objects.getFrame(_thread, _index).apply(item -> item.frame).asExceptionResult();
    }
}