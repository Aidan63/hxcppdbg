package hxcppdbg.core.drivers.dbgeng.native.models;

@:unreflective
@:structAccess
@:include('models/LazyClassFields.hpp')
@:native('hxcppdbg::core::drivers::dbgeng::native::models::LazyClassFields')
extern class LazyClassFields
{
    function count() : Int;
    function field(_name : String) : NativeModelData;
}