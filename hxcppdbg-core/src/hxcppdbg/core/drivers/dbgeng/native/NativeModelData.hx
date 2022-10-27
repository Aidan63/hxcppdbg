package hxcppdbg.core.drivers.dbgeng.native;

import hxcppdbg.core.drivers.dbgeng.native.models.LazyMap;
import hxcppdbg.core.drivers.dbgeng.native.models.LazyArray;
import hxcppdbg.core.drivers.dbgeng.DbgEngMapModel;
import hxcppdbg.core.drivers.dbgeng.DbgEngArrayModel;
import hxcppdbg.core.model.ModelData;

@:include('NativeModelData.hpp')
@:using(NativeModelData.NativeModelDataTools)
extern enum NativeModelData
{
    NNull;
    NInt(i : Int);
    NFloat(f : Float);
    NBool(b : Bool);

    HxString(s : String);
    HxArray(model : cpp.Pointer<LazyArray>);
    HxMap(model : cpp.Pointer<LazyMap>);
}

class NativeModelDataTools
{
    public static function toModelData(_native : NativeModelData) : ModelData
    {
        return switch _native
        {
            case NNull:
                ModelData.MNull;
            case NInt(i):
                ModelData.MInt(i);
            case NFloat(f):
                ModelData.MFloat(f);
            case NBool(b):
                ModelData.MBool(b);
            case HxString(s):
                ModelData.MString(s);
            case HxArray(model):
                ModelData.MArray(new DbgEngArrayModel(model));
            case HxMap(model):
                ModelData.MMap(new DbgEngMapModel(model));
        }
    }
}