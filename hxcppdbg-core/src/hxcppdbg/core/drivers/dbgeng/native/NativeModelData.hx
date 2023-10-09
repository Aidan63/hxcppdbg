package hxcppdbg.core.drivers.dbgeng.native;

import hxcppdbg.core.model.Keyable;
import hxcppdbg.core.model.ModelData;
import hxcppdbg.core.model.Indexable;
import hxcppdbg.core.drivers.dbgeng.DbgEngIndexable;
import hxcppdbg.core.drivers.dbgeng.DbgEngIntMapModel;
import hxcppdbg.core.drivers.dbgeng.DbgEngStringMapModel;
import hxcppdbg.core.drivers.dbgeng.native.models.IDbgEngKeyable;
import hxcppdbg.core.drivers.dbgeng.native.models.DbgEngBaseModel;
import hxcppdbg.core.drivers.dbgeng.native.models.IDbgEngIndexable;

typedef NativeModelDataKeyPair = { name : NativeModelData, data : NativeModelData };

@:include('NativeModelData.hpp')
@:using(NativeModelData.NativeModelDataTools)
extern enum NativeModelData
{
    NNull;
    NInt(i : Int);
    NFloat(f : Float);
    NBool(b : Bool);

    HxString(s : String);
    HxArray(model : cpp.Pointer<IDbgEngIndexable<NativeModelData>>);
    HxIntMap(model : cpp.Pointer<IDbgEngKeyable<Int, NativeModelDataKeyPair>>);
    HxStringMap(model : cpp.Pointer<IDbgEngKeyable<String, NativeModelDataKeyPair>>);
    HxDynamicMap(model : cpp.Pointer<IDbgEngKeyable<cpp.Pointer<DbgEngBaseModel>, NativeModelDataKeyPair>>);

    HxEnum(type : Any, tag : String, model : cpp.Pointer<IDbgEngIndexable<NativeModelData>>);
    HxAnon(model : cpp.Pointer<IDbgEngKeyable<String, NativeNamedModelData>>);
    HxClass(type : Any, model : cpp.Pointer<IDbgEngKeyable<String, NativeNamedModelData>>);

    NPointer(address : cpp.UInt64, dereferenced : NativeModelData);
    NArray(type : String, model : cpp.Pointer<IDbgEngIndexable<NativeModelData>>);
    NType(type : String, model : cpp.Pointer<IDbgEngKeyable<String, NativeNamedModelData>>);
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
                ModelData.MArray(new Indexable(new DbgEngIndexable(model)));
            case HxIntMap(model):
                ModelData.MMap(new Keyable(new DbgEngIntMapModel(model)));
            case HxStringMap(model):
                ModelData.MMap(new Keyable(new DbgEngStringMapModel(model)));
            case HxDynamicMap(model):
                ModelData.MMap(new Keyable(new DbgEngDynamicMapModel(model)));
            case HxEnum(type, tag, model):
                ModelData.MEnum(type, tag, new Indexable(new DbgEngIndexable(model)));
            case HxAnon(model):
                ModelData.MAnon(new Keyable(new DbgEngNamedKeyable(model)));
            case HxClass(type, model):
                ModelData.MClass(type, new Keyable(new DbgEngNamedKeyable(model)));
            case NPointer(address, dereferenced):
                ModelData.MNative(NativeData.NPointer(address.toInt(), dereferenced.toModelData()));
            case NArray(type, model):
                ModelData.MNative(NativeData.NArray(type, new Indexable(new DbgEngIndexable(model))));
            case NType(type, model):
                ModelData.MNative(NativeData.NType(type, new Keyable(new DbgEngNamedKeyable(model))));
        }
    }
}
