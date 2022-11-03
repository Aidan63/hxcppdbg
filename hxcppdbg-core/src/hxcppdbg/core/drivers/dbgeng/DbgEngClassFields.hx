package hxcppdbg.core.drivers.dbgeng;

import cpp.NativeGc;
import haxe.Exception;
import hxcppdbg.core.ds.Result;
import hxcppdbg.core.drivers.dbgeng.native.models.IDbgEngKeyable;

class DbgEngClassFields implements IKeyable<String>
{
    final model : cpp.Pointer<IDbgEngKeyable<String>>;

    public function new(_model)
    {
        model = _model;
        
        NativeGc.addFinalizable(this, false);
    }

    public function finalize()
    {
        model.destroy();
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