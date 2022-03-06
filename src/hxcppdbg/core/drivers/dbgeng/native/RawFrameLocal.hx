package hxcppdbg.core.drivers.dbgeng.native;

@:keep
@:include('RawFrameLocal.hpp')
@:native('hx::ObjectPtr<hxcppdbg::core::drivers::dbgeng::native::RawFrameLocal>')
extern class RawFrameLocal
{
    public final name : String;

    public final type : String;

    public final value : String;
}