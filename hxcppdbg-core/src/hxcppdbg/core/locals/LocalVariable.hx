package hxcppdbg.core.locals;

import hxcppdbg.core.model.Model;
import hxcppdbg.core.locals.NativeLocal;
import hxcppdbg.core.sourcemap.Sourcemap.NameMap;

enum LocalVariable
{
    Native(_model : Model);
    Haxe(_model : Model);
}