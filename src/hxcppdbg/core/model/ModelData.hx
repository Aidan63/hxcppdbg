package hxcppdbg.core.model;

enum ModelData
{
    MNull;
    MInt(i : Int);
    MFloat(f : Float);
    MBool(b : Bool);
    MString(s : String);
    MArray(items : Array<ModelData>);
    MMap(items : Array<Model>);
    MEnum(name : String, arguments : Array<ModelData>);
    MDynamic(inner : ModelData);
    MAnon(fields : Array<Model>);
    MClass(name : String, fields : Array<Model>);
    MUnknown(type : String);
}