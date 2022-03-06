package hxcppdbg.core.drivers.lldb.native;

@:keep
@:include('RawStackLocal.hpp')
@:native('hx::ObjectPtr<hxcppdbg::core::drivers::lldb::native::RawStackLocal>')
extern class RawStackLocal
{
    final name : String;

    final value : String;

    final type : String;
}