package hxcppdbg.core.drivers.dbgeng.model;

import tink.CoreApi.Lazy;
import hxcppdbg.core.model.ModelData;
import hxcppdbg.core.model.IArrayModel;

@:keep class DbgModelArrayModel implements IArrayModel
{
    final model : cpp.Pointer<LazyArray>;

    final cachedElements : Map<Int, ModelData>;

    final elementSize : Lazy<Int>;

    final elements : Lazy<Int>;

    public function new(_model)
    {
        model          = _model;
        cachedElements = [];
        elementSize    = Lazy.ofFunc(() -> model.ptr.elementSize());
        elements       = Lazy.ofFunc(() -> model.ptr.length());
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
                cachedElements[_index] = model.ptr.at(elements.get(), _index);
            case cached:
                cached;
        }
	}
}