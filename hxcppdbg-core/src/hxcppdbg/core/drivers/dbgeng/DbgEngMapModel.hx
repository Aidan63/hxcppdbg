package hxcppdbg.core.drivers.dbgeng;

import cpp.NativeGc;
import hxcppdbg.core.drivers.dbgeng.native.models.LazyMap;
import hxcppdbg.core.model.MapModel;
import tink.CoreApi.Lazy;
import hxcppdbg.core.model.ModelData;

class DbgEngMapModel extends MapModel
{
    final model : cpp.Pointer<LazyMap>;

    final elements : Lazy<Int>;

    final cachedKeys : Map<Int, ModelData>;

    final cachedValues : Map<Int, ModelData>;

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

	public function count() : Int
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

	public function value(_index : Int)
    {
        return switch cachedValues[_index]
        {
            case null:
                cachedValues[_index] = model.ptr.key(_index).toModelData();
            case cached:
                cached;
        }
    }

    function getElements()
    {
        return model.ptr.count();
    }
}