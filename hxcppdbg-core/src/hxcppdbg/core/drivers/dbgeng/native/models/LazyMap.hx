package hxcppdbg.core.drivers.dbgeng.native.models;

import hxcppdbg.core.drivers.dbgeng.native.NativeModelData;

@:unreflective
@:structAccess
@:include('models/LazyMap.hpp')
@:native('hxcppdbg::core::drivers::dbgeng::native::models::LazyMap')
extern class LazyMap
{
    function count() : Int;
    function key(_index : Int) : NativeModelData;
    function value(_index : Int) : NativeModelData;
}