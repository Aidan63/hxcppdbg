package hxcppdbg.core.drivers.dbgeng;

import cpp.NativeGc;
import haxe.Exception;
import haxe.exceptions.NotImplementedException;
import hxcppdbg.core.ds.Result;
import hxcppdbg.core.model.ModelData;
import hxcppdbg.core.model.KeyValuePair;
import hxcppdbg.core.drivers.dbgeng.native.NativeModelData;
import hxcppdbg.core.drivers.dbgeng.native.models.IDbgEngKeyable;
import hxcppdbg.core.drivers.dbgeng.native.models.DbgEngBaseModel;

class DbgEngDynamicMapModel implements IKeyable<ModelData, KeyValuePair>
{
    final model : cpp.Pointer<IDbgEngKeyable<cpp.Pointer<DbgEngBaseModel>, NativeModelDataKeyPair>>;

    public function new(_model)
    {
        model = _model;

        NativeGc.addFinalizable(this, false);
    }

    public function finalize()
    {
        model.destroy();
    }

	public function count() : Result<Int, Exception>
    {
		return try Result.Success(model.ptr.count()) catch (exn) Result.Error(exn);
	}

	public function at(_index : Int) : Result<KeyValuePair, Exception>
    {
		return try Result.Success(toKeyValuePair(model.ptr.at(_index))) catch (exn) Result.Error(exn);
	}

	public function get(_key : ModelData) : Result<ModelData, Exception>
    {
        return switch _key
        {
            case MArray(store), MEnum(_, _, store):
                switch cast(@:privateAccess store.indexModel, DbgEngIndexable)
                {
                    case null:
                        Result.Error(new Exception('Is not of type "DbgEngIndexable"'));
                    case array:
                        try Result.Success(model.ptr.get(@:privateAccess array.model.reinterpret()).toModelData()) catch (exn) Result.Error(exn);
                }
            case MAnon(store), MClass(_, store):
                switch cast(@:privateAccess store.keyModel, DbgEngNamedKeyable)
                {
                    case null:
                        Result.Error(new Exception('Is not of type "DbgEngNamedKeyable"'));
                    case anon:
                        try Result.Success(model.ptr.get(@:privateAccess anon.model.reinterpret()).toModelData()) catch (exn) Result.Error(exn);
                }
            case _:
                Result.Error(new NotImplementedException());
        }
	}

    function toKeyValuePair(_result : NativeModelDataKeyPair)
    {
        return new KeyValuePair(_result.name.toModelData(), _result.data.toModelData());
    }
}