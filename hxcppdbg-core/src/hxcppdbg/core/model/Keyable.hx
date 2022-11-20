package hxcppdbg.core.model;

import haxe.Exception;
import hxcppdbg.core.ds.Result;
import hxcppdbg.core.model.ModelData;
import hxcppdbg.core.drivers.IKeyable;

class Keyable<TKey, TValue> extends Indexable<TValue>
{
    final keyModel : IKeyable<TKey, TValue>;

    final keyCache : Map<Any, Result<ModelData, Exception>>;

    public function new(_model : IKeyable<TKey, TValue>)
    {
        super(_model);
        
        keyModel = _model;
        keyCache = [];
    }

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