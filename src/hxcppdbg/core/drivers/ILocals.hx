package hxcppdbg.core.drivers;

import hxcppdbg.core.locals.NativeLocal;

interface ILocals
{
    function getVariables(_thread : Int, _frame : Int) : Array<NativeLocal>;

    function getArguments(_thread : Int, _frame : Int) : Void;
}