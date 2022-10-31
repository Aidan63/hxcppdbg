package hxcppdbg.core.drivers.dbgeng.native.models;


@:unreflective
@:structAccess
@:include('models/LazyEnumArguments.hpp')
@:native('hxcppdbg::core::drivers::dbgeng::native::models::LazyEnumArguments')
extern class LazyEnumArguments
{
    function count() : Int;
    function at(_index : Int) : NativeModelData;
}