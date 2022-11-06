package hxcppdbg.core.drivers.dbgeng;

import cpp.NativeGc;
import hxcppdbg.core.ds.Result;
import hxcppdbg.core.model.NamedModelData;
import hxcppdbg.core.drivers.dbgeng.native.NativeModelData;
import hxcppdbg.core.drivers.dbgeng.native.models.IDbgEngKeyable;

class DbgEngAnonModel implements IKeyable<String, NamedModelData>
{
    final model : cpp.Pointer<IDbgEngKeyable<String, { name : String, data : NativeModelData }>>;

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

	public function get(_name : String)
    {
		return try Result.Success(model.ptr.get(_name).toModelData()) catch (exn) Result.Error(exn);
	}

    public function at(_index : Int)
    {
        return try Result.Success(toNamedModelData(model.ptr.at(_index))) catch (exn) Result.Error(exn);
    }

    function toNamedModelData(_result : { name : String, data : NativeModelData })
    {
        return new NamedModelData(_result.name, _result.data.toModelData());
    }
}