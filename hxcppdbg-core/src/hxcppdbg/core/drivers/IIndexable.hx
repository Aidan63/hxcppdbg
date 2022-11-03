package hxcppdbg.core.drivers;

import haxe.Exception;
import hxcppdbg.core.ds.Result;
import hxcppdbg.core.model.ModelData;

interface IIndexable
{
    function count() : Result<Int, Exception>;
    function at(_index : Int) : Result<ModelData, Exception>;
}