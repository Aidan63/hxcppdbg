package hxcppdbg.core.model;

interface IMapModel
{
    function count() : Int;

    function element(_index : Int) : Model;
}