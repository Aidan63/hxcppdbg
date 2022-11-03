package hxcppdbg.core.model;

import haxe.Exception;
import hxcppdbg.core.ds.Result;
import hxcppdbg.core.model.ModelData;
import hxcppdbg.core.drivers.IKeyable;

/**
 * Storage of `ModelData` objects which can be keyed into.
 */
class Keyable<TKey> extends Indexable
{
    final keyModel : IKeyable<TKey>;

    final keyCache : Map<Any, Result<ModelData, Exception>>;

    public function new(_model : IKeyable<TKey>)
    {
        super(_model);
        
        keyModel = _model;
        keyCache = [];
    }

    /**
     * Return the `ModelData` for the given key.
     * @param _key Key
     */
    public function get(_key : TKey) : Result<ModelData, Exception>
    {
        return switch keyCache[_key]
        {
            case null:
                keyCache[_key] = keyModel.get(_key);
            case cache:
                cache;
        }
    }
}