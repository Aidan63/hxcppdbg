package hxcppdbg.core.drivers.dbgeng.model;

import hxcppdbg.core.drivers.dbgeng.native.NativeModelData;

@:include('models/LazyModels.hpp')
@:unreflective
@:structAccess
@:native('hxcppdbg::core::drivers::dbgeng::native::models::LazyArray')
extern class LazyArray
{
    function length() : Int;
    function elementSize() : Int;
    function at(_elementSize : Int, _index : Int) : NativeModelData;
}