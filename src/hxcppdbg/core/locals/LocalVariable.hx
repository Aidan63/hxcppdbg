package hxcppdbg.core.locals;

import hxcppdbg.core.locals.NativeLocal;
import hxcppdbg.core.sourcemap.Sourcemap.NameMap;

enum LocalVariable
{
    Native(_native : NativeLocal);
    Haxe(_haxe : NameMap, _native : NativeLocal);
}