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

    MArray(model : Indexable);
    MMap(_type : Keyable<ModelData>);
    
    MEnum(type : GeneratedType, constructor : String, arguments : Indexable);
    MDynamic(inner : ModelData);
    MAnon(model : Keyable<String>);
    MClass(type : GeneratedType, model : Keyable<String>);
    MUnknown(type : String);
}