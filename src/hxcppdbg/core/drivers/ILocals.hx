package hxcppdbg.core.drivers;

import haxe.Exception;
import hxcppdbg.core.ds.Result;
import hxcppdbg.core.locals.NativeLocal;

interface ILocals
{
    function getVariables(_thread : Int, _frame : Int) : Result<Array<NativeLocal>, Exception>;

    function getArguments(_thread : Int, _frame : Int) : Result<Array<NativeLocal>, Exception>;
}