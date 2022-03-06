package hxcppdbg.core.drivers.dbgeng.utils;

import haxe.Exception;

class HResultException extends Exception
{
    public final hresult : Int;

    public function new(_message, _hresult)
    {
        super(_message);

        hresult = _hresult;
    }
}