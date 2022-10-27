package hxcppdbg.core.drivers.dbgeng;

import hxcppdbg.core.drivers.dbgeng.native.models.LazyMap;
import hxcppdbg.core.model.MapModel;
import haxe.exceptions.NotImplementedException;
import tink.CoreApi.Lazy;
import hxcppdbg.core.model.Model;

class DbgEngMapModel extends MapModel
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