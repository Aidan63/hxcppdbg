package hxcppdbg.core.drivers;

import haxe.Exception;
import hxcppdbg.core.ds.Result;
import hxcppdbg.core.model.Model;

interface ILocals
{
    function getVariables(_thread : Int, _frame : Int, _callback : Result<ILocalStore, Exception>->Void) : Void;

    function getArguments(_thread : Int, _frame : Int, _callback : Result<Array<Model>, Exception>->Void) : Void;
}