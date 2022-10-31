package hxcppdbg.core.drivers.dbgeng;

import cpp.NativeGc;
import tink.CoreApi.Lazy;
import hxcppdbg.core.drivers.dbgeng.native.models.LazyAnonFields;
import hxcppdbg.core.model.ModelData;
import hxcppdbg.core.model.NamedModel;

class DbgEngAnonModel extends NamedModel
{
    final model : cpp.Pointer<LazyAnonFields>;

    final cachedCount : Lazy<Int>;

    final cachedFields : Map<String, ModelData>;

    public function new(_model)
    {
        model        = _model;
        cachedCount  = Lazy.ofFunc(getCount);
        cachedFields = [];

        NativeGc.addFinalizable(this, false);
    }

    public function finalize()
    {
        model.destroy();
    }

	public function count()
    {
		return cachedCount.get();
	}

	public function field(_name : String)
    {
		return switch cachedFields[_name]
        {
            case null:
                cachedFields[_name] = model.ptr.field(_name).toModelData();
            case cached:
                cached;
        }
	}

    function getCount()
    {
        return model.ptr.count();
    }
}