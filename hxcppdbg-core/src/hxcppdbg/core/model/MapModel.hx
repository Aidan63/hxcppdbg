package hxcppdbg.core.model;

abstract class MapModel<T>
{
    public abstract function count() : Int;

    public abstract function key(_index : Int) : ModelData;

    public abstract function value(_key : T) : ModelData;
}