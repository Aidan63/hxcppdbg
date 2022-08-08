package hxcppdbg.dap;

import haxe.Exception;

enum DapResponse
{
    Success(body : Null<Any>);
    Failure(exn : Exception);
}