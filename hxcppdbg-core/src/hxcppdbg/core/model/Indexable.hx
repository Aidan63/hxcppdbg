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

    public function at(_index : Int) : Result<TValue, Exception>
    {
        return switch indexCache[_index]
        {
            case null:
                indexCache[_index] = indexModel.at(_index);
            case cached:
                cached;
        }
    }
}