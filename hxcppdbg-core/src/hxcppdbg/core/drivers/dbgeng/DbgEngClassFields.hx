package hxcppdbg.core.drivers.dbgeng;

import cpp.NativeGc;
import hxcppdbg.core.model.NamedModel;
import hxcppdbg.core.model.ModelData;
import hxcppdbg.core.drivers.dbgeng.native.models.LazyClassFields;

class DbgEngClassFields extends NamedModel
{
    final model : cpp.Pointer<LazyClassFields>;

    final cachedFields : Map<String, ModelData>;

    public function new(_model)
    {
        model        = _model;
        cachedFields = [];
        
        NativeGc.addFinalizable(this, false);
    }

    public function finalize()
    {
        model.destroy();
    }

	public function count()
    {
		return model.ptr.count();
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
}