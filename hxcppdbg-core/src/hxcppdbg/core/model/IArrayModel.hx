package hxcppdbg.core.model;

interface IArrayModel
{
    function length() : Int;

    function at(_index : Int) : ModelData;
}