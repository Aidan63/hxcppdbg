package hxcppdbg.core.drivers.dbgeng.native.models;

@:unreflective
@:structAccess
@:include('models/LazyAnonFields.hpp')
@:native('hxcppdbg::core::drivers::dbgeng::native::models::LazyAnonFields')
extern class LazyAnonFields
{
    function count() : Int;
    function field(_name : String) : NativeModelData;
}