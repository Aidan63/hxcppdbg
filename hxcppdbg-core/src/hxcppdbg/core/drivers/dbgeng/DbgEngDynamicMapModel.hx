package hxcppdbg.core.drivers.dbgeng;

import cpp.NativeGc;
import haxe.Exception;
import haxe.exceptions.NotImplementedException;
import hxcppdbg.core.ds.Result;
import hxcppdbg.core.model.ModelData;
import hxcppdbg.core.model.KeyValuePair;
import hxcppdbg.core.drivers.dbgeng.native.NativeModelData;
import hxcppdbg.core.drivers.dbgeng.native.models.LazyDynamicMap;

class DbgEngDynamicMapModel implements IKeyable<ModelData, KeyValuePair>
{
    final model : cpp.Pointer<LazyDynamicMap>;

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
            case MArray(store):
                switch cast(@:privateAccess store.indexModel, DbgEngArrayModel)
                {
                    case null:
                        Result.Error(new Exception('Array store is not of type "DbgEngArrayModel"'));
                    case array:
                        final ref = @:privateAccess array.model.ref;

                        try Result.Success(model.ptr.get(ref).toModelData()) catch (exn) Result.Error(exn);
                }
            case MEnum(_, _, store):
                switch cast(@:privateAccess store.indexModel, DbgEngEnumArguments)
                {
                    case null:
                        Result.Error(new Exception('Enum store is not of type "DbgEngEnumArguments"'));
                    case args:
                        final ref = @:privateAccess args.model.ref;

                        try Result.Success(model.ptr.get(ref).toModelData()) catch (exn) Result.Error(exn);
                }
            case MAnon(store):
                switch cast(@:privateAccess store.keyModel, DbgEngAnonModel)
                {
                    case null:
                        Result.Error(new Exception('Anon object store is not of type "DbgEngAnonModel"'));
                    case anon:
                        final ref = @:privateAccess anon.model.ref;

                        try Result.Success((model.ptr.get(ref) : NativeModelData).toModelData()) catch (exn) Result.Error(exn);
                }
            case MClass(_, store):
                switch cast(@:privateAccess store.keyModel, DbgEngClassFields)
                {
                    case null:
                        Result.Error(new Exception('Class fields store is not of type "DbgEngClassFields"'));
                    case cls:
                        final ref = @:privateAccess cls.model.ref;

                        try Result.Success((model.ptr.get(ref) : NativeModelData).toModelData()) catch (exn) Result.Error(exn);
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