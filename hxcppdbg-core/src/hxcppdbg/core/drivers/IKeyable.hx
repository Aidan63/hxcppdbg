package hxcppdbg.core.drivers;

import haxe.Exception;
import hxcppdbg.core.ds.Result;
import hxcppdbg.core.model.ModelData;

interface IKeyable<TKey> extends IIndexable
{
    function get(_key : TKey) : Result<ModelData, Exception>;
}