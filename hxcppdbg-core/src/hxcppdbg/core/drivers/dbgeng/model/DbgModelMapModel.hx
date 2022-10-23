package hxcppdbg.core.drivers.dbgeng.model;

import cpp.Pointer;
import cpp.Reference;
import tink.CoreApi.Lazy;
import hxcppdbg.core.model.Model;
import hxcppdbg.core.model.IMapModel;

@:keep class DbgModelMapModel implements IMapModel
{
    final model : cpp.Pointer<LazyMap>;

    final elements : Lazy<Int>;

    final cachedElements : Map<Int, Model>;

    public function new(_model)
    {
        model          = _model;
        elements       = Lazy.ofFunc(() -> model.ptr.count());
        cachedElements = [];
    }

	public function count() : Int
    {
		return elements.get();
	}

	public function element(_index : Int) : Model
    {
        return switch cachedElements[_index]
        {
            case null:
                cachedElements[_index] = model.ptr.child(_index);
            case cached:
                cached;
        }
	}
}