package hxcppdbg.core.drivers.dbgeng;

import hxcppdbg.core.drivers.dbgeng.native.models.LazyEnumArguments;
import hxcppdbg.core.model.ModelData;
import hxcppdbg.core.model.EnumArguments;

class DbgEngEnumArguments extends EnumArguments
{
	final model : cpp.Pointer<LazyEnumArguments>;

	final cachedArgs : Map<Int, ModelData>;

	public function new(_model)
	{
		model      = _model;
		cachedArgs = [];
	}

	public function count()
    {
		return model.ptr.count();
	}

	public function at(_index : Int)
    {
		return switch cachedArgs[_index]
		{
			case null:
				cachedArgs[_index] = model.ptr.at(_index).toModelData();
			case cached:
				cached;
		}
	}
}