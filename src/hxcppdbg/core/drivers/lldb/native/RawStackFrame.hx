package hxcppdbg.core.drivers.lldb.native;

@:keep
@:include('RawStackFrame.hpp')
@:native('hx::ObjectPtr<hxcppdbg::core::drivers::lldb::native::RawStackFrame>')
extern class RawStackFrame
{
    final file : String;

    final func : String;

    final symbol : String;

    final line : Int;
}