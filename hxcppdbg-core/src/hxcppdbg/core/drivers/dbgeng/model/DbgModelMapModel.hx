package hxcppdbg.core.drivers.dbgeng.model;

import haxe.exceptions.NotImplementedException;
import tink.CoreApi.Lazy;
import hxcppdbg.core.model.Model;
import hxcppdbg.core.model.IMapModel;

class DbgModelMapModel implements IMapModel
{
    final model : cpp.Pointer<LazyMap>;

    final elements : Lazy<Int>;

    final cachedElements : Map<Int, Model>;

    public function new(_model)
    {
        model          = _model;
        elements       = Lazy.ofFunc(getElements);
        cachedElements = [];
    }

	public function count() : Int
    {
		return elements.get();
	}

	public function element(_index : Int) : Model
    {
        throw new NotImplementedException();
        // return switch cachedElements[_index]
        // {
        //     case null:
        //         cachedElements[_index] = model.ptr.child(_index).toModelData();
        //     case cached:
        //         cached;
        // }
	}

    function getElements()
    {
        return model.ptr.count();
    }
}