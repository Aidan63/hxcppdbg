package hxcppdbg.core.model;

import haxe.Int64;
import hxcppdbg.core.model.Keyable;
import hxcppdbg.core.model.Indexable;
import hxcppdbg.core.sourcemap.Sourcemap.GeneratedType;

@:using(hxcppdbg.core.model.Printer)
enum ModelData
{
    MNull;
    MInt(i : Int);
    MFloat(f : Float);
    MBool(b : Bool);
    MString(s : String);
    MArray(model : Indexable<ModelData>);
    MMap(type : Keyable<ModelData, KeyValuePair>);
    MEnum(type : GeneratedType, constructor : String, arguments : Indexable<ModelData>);
    MAnon(model : Keyable<String, NamedModelData>);
    MClass(type : GeneratedType, model : Keyable<String, NamedModelData>);
    MNative(native : NativeData);
}

enum NativeData
{
    NPointer(address : Int64, dereferenced : ModelData);
    NType(type : String, model : Keyable<String, NamedModelData>);
    NArray(type : String, model : Indexable<ModelData>);
    NUnknown(type : String);
}