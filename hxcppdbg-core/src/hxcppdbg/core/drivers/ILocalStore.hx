package hxcppdbg.core.drivers;

import hxcppdbg.core.model.ModelData;

interface ILocalStore
{
    function local(_name : String) : ModelData;

    function locals() : Array<String>;
}