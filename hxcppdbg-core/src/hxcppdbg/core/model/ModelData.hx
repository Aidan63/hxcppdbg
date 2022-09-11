package hxcppdbg.core.model;

import hxcppdbg.core.sourcemap.Sourcemap.GeneratedType;

enum ModelData
{
    MNull;
    MInt(i : Int);
    MFloat(f : Float);
    MBool(b : Bool);
    MString(s : String);
    MArray(items : Array<ModelData>);
    MMap(items : Array<Model>);
    MEnum(type : GeneratedType, constructor : String, arguments : Array<ModelData>);
    MDynamic(inner : ModelData);
    MAnon(fields : Array<Model>);
    MClass(type : GeneratedType, fields : Array<Model>);
    MUnknown(type : String);
}