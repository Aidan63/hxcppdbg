package hxcppdbg.core.model;

abstract class NamedModel
{
    public abstract function count() : Int;

    public abstract function field(_name : String) : ModelData;
}