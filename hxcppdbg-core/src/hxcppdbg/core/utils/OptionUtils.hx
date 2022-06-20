package hxcppdbg.core.utils;

import haxe.Exception;
import haxe.ds.Option;

function asExceptionOption<E : Exception>(_option : Option<E>) : Option<Exception>
{
    return switch _option
    {
        case Some(v):
            Option.Some(v);
        case None:
            Option.None;
    }
}