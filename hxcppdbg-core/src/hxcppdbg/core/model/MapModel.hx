package hxcppdbg.core.model;

abstract class MapModel
{
    public abstract function count() : Int;

    public abstract function value(_key : ModelData) : ModelData;

    public abstract function key(_index : Int) : ModelData;
}