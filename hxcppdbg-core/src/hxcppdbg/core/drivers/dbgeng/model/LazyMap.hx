package hxcppdbg.core.drivers.dbgeng.model;

import hxcppdbg.core.model.Model;

@:keep
@:unreflective
@:structAccess
@:include('models/LazyModels.hpp')
@:native('hxcppdbg::core::drivers::dbgeng::native::models::LazyMap')
extern class LazyMap
{
    function count() : Int;
    function child(_index : Int) : Model;
}