package hxcppdbg.core.drivers.dbgeng.native.models;

@:unreflective
@:structAccess
@:include('models/IDbgEngKeyable.hpp')
@:native('hxcppdbg::core::drivers::dbgeng::native::models::IDbgEngKeyable')
extern class IDbgEngKeyable<TKey, TValue> extends IDbgEngIndexable<TValue>
{
    function get(_key : TKey) : NativeModelData;
}