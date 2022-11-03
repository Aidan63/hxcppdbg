package hxcppdbg.core.drivers.dbgeng.native.models;

@:unreflective
@:structAccess
@:include('models/IDbgEngKeyable.hpp')
@:native('hxcppdbg::core::drivers::dbgeng::native::models::IDbgEngKeyable')
extern class IDbgEngKeyable<TKey> extends IDbgEngIndexable
{
    function get(_key : TKey) : NativeModelData;
}