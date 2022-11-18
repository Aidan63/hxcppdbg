package hxcppdbg.core.locals;

import hxcppdbg.core.model.ModelData;
import hxcppdbg.core.locals.NativeLocal;
import hxcppdbg.core.sourcemap.Sourcemap.NameMap;

enum LocalVariable
{
    Native(_name : String, _model : ModelData);
    Haxe(_name : String, _model : ModelData);
}