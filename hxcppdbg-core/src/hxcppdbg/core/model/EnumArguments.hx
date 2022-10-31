package hxcppdbg.core.model;

abstract class EnumArguments
{
    public abstract function count() : Int;

    abstract public function at(_index : Int) : ModelData;
}