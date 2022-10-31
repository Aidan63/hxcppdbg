package hxcppdbg.core.model;

import hxcppdbg.core.sourcemap.Sourcemap.GeneratedType;

enum ModelData
{
    MNull;
    MInt(i : Int);
    MFloat(f : Float);
    MBool(b : Bool);
    MString(s : String);

    MArray(model : ArrayModel);
    MMap(_type : MapModel);
    
    MEnum(type : GeneratedType, constructor : String, arguments : EnumArguments);
    MDynamic(inner : ModelData);
    MAnon(model : NamedModel);
    MClass(type : GeneratedType, fields : Array<Model>);
    MUnknown(type : String);
}