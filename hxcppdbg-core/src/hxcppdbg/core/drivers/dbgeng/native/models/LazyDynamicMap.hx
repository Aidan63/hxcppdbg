package hxcppdbg.core.drivers.dbgeng.native.models;

import hxcppdbg.core.drivers.dbgeng.native.NativeModelData.NamedNativeModelData;

@:unreflective
@:structAccess
@:include('models/LazyMap.hpp')
@:native('hxcppdbg::core::drivers::dbgeng::native::models::LazyDynamicMap')
extern class LazyDynamicMap extends IDbgEngIndexable<Dynamic>
{
    function at(_index : Int) : Dynamic;

    overload function get(_key : cpp.Reference<IDbgEngIndexable<NativeModelData>>) : NativeModelData;

    overload function get(_key : cpp.Reference<IDbgEngIndexable<NamedNativeModelData>>) : Dynamic;
}