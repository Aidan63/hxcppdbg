package hxcppdbg.core.drivers.dbgeng.native.models;

@:unreflective
@:structAccess
@:include('models/LazyLocalStore.hpp')
@:native('hxcppdbg::core::drivers::dbgeng::native::models::LazyLocalStore')
extern class LazyLocalStore
{
    function locals() : Array<String>;
    function local(_name : String) : NativeModelData;
}