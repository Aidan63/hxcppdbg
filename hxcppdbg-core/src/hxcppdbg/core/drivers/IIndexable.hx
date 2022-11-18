package hxcppdbg.core.drivers;

import haxe.Exception;
import hxcppdbg.core.ds.Result;

interface IIndexable<TValue>
{
    function count() : Result<Int, Exception>;
    function at(_index : Int) : Result<TValue, Exception>;
}