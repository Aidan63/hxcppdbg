package hxcppdbg.core.drivers.dbgeng.native.models;

import hxcppdbg.core.drivers.dbgeng.native.NativeModelData;

@:unreflective
@:structAccess
@:include('models/LazyArray.hpp')
@:native('hxcppdbg::core::drivers::dbgeng::native::models::LazyArray')
extern class LazyArray
{
    function length() : Int;
    function elementSize() : Int;
    function at(_elementSize : Int, _index : Int) : NativeModelData;
}