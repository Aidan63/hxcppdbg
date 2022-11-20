package hxcppdbg.core.drivers.dbgeng;

import cpp.NativeGc;
import hxcppdbg.core.ds.Result;
import hxcppdbg.core.model.ModelData;
import hxcppdbg.core.drivers.dbgeng.native.NativeModelData;
import hxcppdbg.core.drivers.dbgeng.native.models.IDbgEngIndexable;

class DbgEngEnumArguments implements IIndexable<ModelData>
{
	final model : cpp.Pointer<IDbgEngIndexable<NativeModelData>>;

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

	public function at(_index : Int)
    {
		final m : NativeModelData = untyped __cpp__('this->model->ptr->at({0})', _index);

		return try Result.Success(m.toModelData()) catch (exn) Result.Error(exn);
	}
}