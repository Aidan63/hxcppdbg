package hxcppdbg.core.model;

import tink.CoreApi.Lazy;
import haxe.Exception;
import hxcppdbg.core.ds.Result;
import hxcppdbg.core.drivers.IIndexable;

class Indexable<TValue>
{
    final indexModel : IIndexable<TValue>;
    
    final indexCache : Map<Int, Result<TValue, Exception>>;

    final lazyCount : Lazy<Result<Int, Exception>>;

    public function new(_model)
    {
        indexModel = _model;
        indexCache = [];
        lazyCount  = Lazy.ofFunc(indexModel.count);
    }

    public function count() : Result<Int, Exception>
    {
        return lazyCount.get();
    }

    public function at(_index : Int, _refresh = false) : Result<TValue, Exception>
    {
        return if (_refresh || !indexCache.exists(_index))
        {
            indexCache[_index] = indexModel.at(_index);
        }
        else
        {
            indexCache[_index];
        }
    }
}