package hxcppdbg.core.drivers.dbgeng.native;

@:keep
@:include('RawStackFrame.hpp')
@:native('hx::ObjectPtr<hxcppdbg::core::drivers::dbgeng::native::RawStackFrame>')
extern class RawStackFrame
{
    public final file : String;

    public final symbol : String;

    public final line : Int;

    public final address : cpp.UInt64;
}