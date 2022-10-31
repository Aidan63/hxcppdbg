package hxcppdbg.core.model;

import hxcppdbg.core.model.EnumArguments;
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
    MAnon(fields : Array<Model>);
    MClass(type : GeneratedType, fields : Array<Model>);
    MUnknown(type : String);
}