package hxcppdbg.core.drivers.dbgeng.native;

import hxcppdbg.core.model.Keyable;
import hxcppdbg.core.model.ModelData;
import hxcppdbg.core.model.Indexable;
import hxcppdbg.core.drivers.dbgeng.DbgEngArrayModel;
import hxcppdbg.core.drivers.dbgeng.DbgEngIntMapModel;
import hxcppdbg.core.drivers.dbgeng.DbgEngStringMapModel;
import hxcppdbg.core.drivers.dbgeng.native.models.IDbgEngKeyable;
import hxcppdbg.core.drivers.dbgeng.native.models.IDbgEngIndexable;
import hxcppdbg.core.sourcemap.Sourcemap.GeneratedType;

@:include('NativeModelData.hpp')
@:using(NativeModelData.NativeModelDataTools)
extern enum NativeModelData
{
    NNull;
    NInt(i : Int);
    NFloat(f : Float);
    NBool(b : Bool);

    HxString(s : String);
    HxArray(model : cpp.Pointer<IDbgEngIndexable>);
    HxIntMap(model : cpp.Pointer<IDbgEngKeyable<Int>>);
    HxStringMap(model : cpp.Pointer<IDbgEngKeyable<String>>);

    HxEnum(type : GeneratedType, tag : String, model : cpp.Pointer<IDbgEngIndexable>);
    HxAnon(model : cpp.Pointer<IDbgEngKeyable<String>>);
    HxClass(type : GeneratedType, model : cpp.Pointer<IDbgEngKeyable<String>>);
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
                ModelData.MArray(new Indexable(new DbgEngArrayModel(model)));
            case HxIntMap(model):
                ModelData.MMap(new Keyable<ModelData>(new DbgEngIntMapModel(model)));
            case HxStringMap(model):
                ModelData.MMap(new Keyable<ModelData>(new DbgEngStringMapModel(model)));
            case HxEnum(type, tag, model):
                ModelData.MEnum(type, tag, new Indexable(new DbgEngEnumArguments(model)));
            case HxAnon(model):
                ModelData.MAnon(new Keyable<String>(new DbgEngAnonModel(model)));
            case HxClass(type, model):
                ModelData.MClass(type, new Keyable<String>(new DbgEngClassFields(model)));
        }
    }
}