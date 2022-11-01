package hxcppdbg.core.drivers.dbgeng;

import hxcppdbg.core.drivers.dbgeng.native.models.LazyLocalStore;

class DbgEngLocalStore implements ILocalStore
{
	final model : cpp.Pointer<LazyLocalStore>;

	public function new(_model)
	{
		model = _model;
	}

	public function local(_name:String)
	{
		return model.ptr.local(_name).toModelData();
	}

	public function locals() : Array<String>
	{
		return model.ptr.locals();
	}
}