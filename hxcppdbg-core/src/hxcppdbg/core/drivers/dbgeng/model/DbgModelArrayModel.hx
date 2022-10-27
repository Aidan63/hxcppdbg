package hxcppdbg.core.drivers.dbgeng.model;

import cpp.Finalizable;
import tink.CoreApi.Lazy;
import hxcppdbg.core.model.ModelData;
import hxcppdbg.core.model.IArrayModel;

class DbgModelArrayModel extends Finalizable implements IArrayModel
{
    final model : cpp.Pointer<LazyArray>;

    final cachedElements : Map<Int, ModelData>;

    final elementSize : Lazy<Int>;

    final elements : Lazy<Int>;

    public function new(_model)
    {
        super();

        model          = _model;
        cachedElements = [];
        elementSize    = Lazy.ofFunc(getElementSize);
        elements       = Lazy.ofFunc(getLength);
    }

    public override function finalize()
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
                final o = model.ptr.at(elements.get(), _index);
                final c = o.toModelData();

                cachedElements[_index] = c;
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