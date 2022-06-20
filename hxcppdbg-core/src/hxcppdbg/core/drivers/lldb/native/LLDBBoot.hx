package hxcppdbg.core.drivers.lldb.native;

@:keep
@:unreflective
@:include('LLDBBoot.hpp')
@:build(hxcppdbg.core.utils.HxcppUtils.xml('LLDB'))
extern class LLDBBoot
{
    @:native('hxcppdbg::core::drivers::lldb::native::boot')
    static function boot() : Void;
}