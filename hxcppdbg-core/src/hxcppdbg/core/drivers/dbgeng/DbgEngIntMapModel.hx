package hxcppdbg.core.drivers.dbgeng;

import cpp.NativeGc;
import haxe.Exception;
import hxcppdbg.core.ds.Result;
import hxcppdbg.core.model.ModelData;
import hxcppdbg.core.drivers.dbgeng.native.models.IDbgEngKeyable;

class DbgEngIntMapModel implements IKeyable<ModelData>
{
    final model : cpp.Pointer<IDbgEngKeyable<Int>>;

    public function new(_model)
    {
        model = _model;

        NativeGc.addFinalizable(this, false);
    }

	public function count()
    {
		return try Result.Success(model.ptr.count()) catch (exn) Result.Error(exn);
	}

	public function get(_key : ModelData)
    {
        return switch _key
        {
            case MInt(i), MDynamic(MInt(i)):
                try Result.Success(model.ptr.get(i).toModelData()) catch (exn) Result.Error(exn);
            case other:
                Result.Error(new Exception('Cannot key into a haxe.ds.IntMap with $other'));
        }
	}

	public function at(_index : Int)
    {
		return try Result.Success(model.ptr.at(_index).toModelData()) catch (exn) Result.Error(exn);
	}

    public function finalize()
    {
        model.destroy();
    }
}