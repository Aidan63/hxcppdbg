package hxcppdbg.core.ds;

import haxe.Exception;

enum Result<T, E : Exception> {
    Success(v : T);
    Error(e : E);
}