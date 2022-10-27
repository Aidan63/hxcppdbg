package hxcppdbg.core.drivers.dbgeng;

import cpp.NativeGc;
import hxcppdbg.core.drivers.dbgeng.native.models.LazyArray;
import hxcppdbg.core.model.ArrayModel;
import tink.CoreApi.Lazy;
import hxcppdbg.core.model.ModelData;

class DbgEngArrayModel extends ArrayModel
{
    final model : cpp.Pointer<LazyArray>;

    final cachedElements : Map<Int, ModelData>;

    final elementSize : Lazy<Int>;

    final elements : Lazy<Int>;

    public function new(_model)
    {
        model          = _model;
        cachedElements = [];
        elementSize    = Lazy.ofFunc(getElementSize);
        elements       = Lazy.ofFunc(getLength);

        NativeGc.addFinalizable(this, false);
    }

    public function finalize()
    {
        model.destroy();
    }

	public function length() : Int
    {
		return elements.get();
	}

	public function at(_index : Int) : ModelData
    {
        return switch cachedElements[_index]
        {
            case null:
                cachedElements[_index] = model.ptr.at(elements.get(), _index).toModelData();
            case cached:
                cached;
        }
	}

    function getElementSize()
    {
        return model.ptr.elementSize();
    }

    function getLength()
    {
        return model.ptr.length();
    }
}