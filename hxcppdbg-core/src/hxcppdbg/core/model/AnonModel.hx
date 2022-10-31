package hxcppdbg.core.model;

abstract class AnonModel
{
    public abstract function count() : Int;

    public abstract function field(_name : String) : ModelData;
}