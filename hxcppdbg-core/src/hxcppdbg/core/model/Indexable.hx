package hxcppdbg.core.model;

import tink.CoreApi.Lazy;
import haxe.Exception;
import haxe.ds.Vector;
import haxe.exceptions.NotImplementedException;
import hxcppdbg.core.ds.Result;
import hxcppdbg.core.drivers.IIndexable;

/**
 * Storage of `ModelData` objects which can be index into.
 */
class Indexable
{
    final indexModel : IIndexable;
    
    final indexCache : Map<Int, Result<ModelData, Exception>>;

    final lazyCount : Lazy<Result<Int, Exception>>;

    public function new(_model)
    {
        indexModel = _model;
        indexCache = [];
        lazyCount  = Lazy.ofFunc(getCount);
    }

    /**
     * Get the number of items in the store.
     */
    public function count() : Result<Int, Exception>
    {
        return lazyCount.get();
    }

    /**
     * Return the `ModelData` at the given index.
     * @param _index 
     * @return Result<ModelData, Exception>
     */
    public function at(_index : Int) : Result<ModelData, Exception>
    {
        return switch indexCache[_index]
        {
            case null:
                indexCache[_index] = indexModel.at(_index);
            case cached:
                cached;
        }
    }

    function getCount()
    {
        return indexModel.count();
    }
}