package hxcppdbg.core.drivers.dbgeng;

import cpp.NativeGc;
import haxe.Exception;
import hxcppdbg.core.ds.Result;
import hxcppdbg.core.model.ModelData;
import hxcppdbg.core.model.KeyValuePair;
import hxcppdbg.core.drivers.dbgeng.native.NativeModelData;
import hxcppdbg.core.drivers.dbgeng.native.models.IDbgEngKeyable;

class DbgEngStringMapModel implements IKeyable<ModelData, KeyValuePair>
{
    final model : cpp.Pointer<IDbgEngKeyable<String, NativeModelDataKeyPair>>;

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

	public function get(_key : ModelData)
    {
        return switch _key
        {
            case MString(s), MDynamic(MString(s)):
                try Result.Success(model.ptr.get(s).toModelData()) catch (exn) Result.Error(exn);
            case other:
                Result.Error(new Exception('Cannot key into a haxe.ds.IntMap with $other'));
        }
	}

	public function at(_index : Int)
    {
		return try Result.Success(toKeyValuePair(model.ptr.at(_index))) catch (exn) Result.Error(exn);
	}

    function toKeyValuePair(_result : NativeModelDataKeyPair)
    {
        return new KeyValuePair(_result.name.toModelData(), _result.data.toModelData());
    }
}