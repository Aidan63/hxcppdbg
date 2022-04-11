package hxcppdbg.core.model;

enum ModelData
{
    MNull;
    MInt(v : Int);
    MFloat(v : Float);
    MBool(v : Bool);
    MString(v : String);
    MArray(v : Array<ModelData>);
    MMap(v : Array<Model>);
    MEnum(tag : String, arguments : Array<Model>);
    MDynamic(v : ModelData);
    MAnon(v : Array<ModelData>);
    MUnknown(v : String);
}