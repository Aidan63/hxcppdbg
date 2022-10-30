package hxcppdbg.core.drivers.dbgeng;

import haxe.Exception;
import cpp.NativeGc;
import tink.CoreApi.Lazy;
import hxcppdbg.core.drivers.dbgeng.native.models.LazyMap;
import hxcppdbg.core.model.ModelData;
import hxcppdbg.core.model.MapModel;

class DbgEngStringMapModel extends MapModel
{
    final model : cpp.Pointer<LazyMap>;

    final elements : Lazy<Int>;

    final cachedKeys : Map<Int, ModelData>;

    final cachedValues : Map<String, ModelData>;

    public function new(_model)
    {
        model        = _model;
        elements     = Lazy.ofFunc(getElements);
        cachedKeys   = [];
        cachedValues = [];

        NativeGc.addFinalizable(this, false);
    }

    public function finalize()
    {
        model.destroy();
    }

	public function count()
    {
		return elements.get();
	}

	public function key(_index : Int)
    {
		return switch cachedKeys[_index]
        {
            case null:
                cachedKeys[_index] = model.ptr.key(_index).toModelData();
            case cached:
                cached;
        }
	}

	public function value(_key : ModelData)
    {
        return switch _key
        {
            case MString(s), MDynamic(MString(s)):
                switch cachedValues[s]
                {
                    case null:
                        cachedValues[s] = model.ptr.value(s).toModelData();
                    case cached:
                        cached;
                }
            case _:
                throw new Exception('Key to a haxe.ds.StringMap should be String');
        }
	}

    function getElements()
    {
        return model.ptr.count();
    }
}