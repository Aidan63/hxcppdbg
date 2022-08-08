package hxcppdbg.dap;

import haxe.Exception;

enum DapResponse
{
    Success();
    Failure(exn : Exception);
}