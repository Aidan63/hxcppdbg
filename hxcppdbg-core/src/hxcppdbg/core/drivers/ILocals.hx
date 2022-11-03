package hxcppdbg.core.drivers;

import haxe.Exception;
import hxcppdbg.core.ds.Result;

interface ILocals
{
    function getVariables(_thread : Int, _frame : Int, _callback : Result<IKeyable<String>, Exception>->Void) : Void;

    function getArguments(_thread : Int, _frame : Int, _callback : Result<IKeyable<String>, Exception>->Void) : Void;
}