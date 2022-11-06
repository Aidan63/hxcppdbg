package hxcppdbg.core.drivers;

import hxcppdbg.core.model.NamedModelData;
import haxe.Exception;
import hxcppdbg.core.ds.Result;

interface ILocals
{
    function getVariables(_thread : Int, _frame : Int, _callback : Result<IKeyable<String, NamedModelData>, Exception>->Void) : Void;

    function getArguments(_thread : Int, _frame : Int, _callback : Result<IKeyable<String, NamedModelData>, Exception>->Void) : Void;
}