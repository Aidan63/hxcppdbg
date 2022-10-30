package hxcppdbg.core.model;

import hxcppdbg.core.sourcemap.Sourcemap.GeneratedType;

enum MapType
{
    KInt(model : MapModel<Int>);
    KString(model : MapModel<String>);
}

enum ModelData
{
    MNull;
    MInt(i : Int);
    MFloat(f : Float);
    MBool(b : Bool);
    MString(s : String);

    MArray(model : ArrayModel);
    MMap(_type : MapType);
    
    MEnum(type : GeneratedType, constructor : String, arguments : Array<ModelData>);
    MDynamic(inner : ModelData);
    MAnon(fields : Array<Model>);
    MClass(type : GeneratedType, fields : Array<Model>);
    MUnknown(type : String);
}