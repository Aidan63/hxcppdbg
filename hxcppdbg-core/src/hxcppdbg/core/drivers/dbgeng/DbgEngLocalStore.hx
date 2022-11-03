package hxcppdbg.core.drivers.dbgeng;

import haxe.Exception;
import hxcppdbg.core.ds.Result;
import hxcppdbg.core.drivers.dbgeng.native.models.IDbgEngKeyable;

class DbgEngLocalStore implements IKeyable<String>
{
	final model : cpp.Pointer<IDbgEngKeyable<String>>;

	public function new(_model)
	{
		model = _model;
	}

	public function count()
	{
		return try Result.Success(model.ptr.count()) catch (exn) Result.Error(exn);
	}

	public function get(_key : String)
	{
		return try Result.Success(model.ptr.get(_key).toModelData()) catch (exn) Result.Error(exn);
	}

	public function at(_index : Int)
	{
		return try Result.Success(model.ptr.at(_index).toModelData()) catch (exn) Result.Error(exn);
	}
}