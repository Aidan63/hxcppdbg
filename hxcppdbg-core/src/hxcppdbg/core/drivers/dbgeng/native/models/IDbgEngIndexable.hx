package hxcppdbg.core.drivers.dbgeng.native.models;

@:unreflective
@:structAccess
@:include('models/IDbgEngIndexable.hpp')
@:native('hxcppdbg::core::drivers::dbgeng::native::models::IDbgEngIndexable')
extern class IDbgEngIndexable<TValue> extends DbgEngBaseModel
{
    function count() : Int;
    function at(_index : Int) : TValue;
}