package hxcppdbg.core.model;

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
    MMap(_type : Keyable<ModelData, KeyValuePair>);
    
    MEnum(type : GeneratedType, constructor : String, arguments : Indexable<ModelData>);
    MDynamic(inner : ModelData);
    MAnon(model : Keyable<String, NamedModelData>);
    MClass(type : GeneratedType, model : Keyable<String, NamedModelData>);
    MUnknown(type : String);
}