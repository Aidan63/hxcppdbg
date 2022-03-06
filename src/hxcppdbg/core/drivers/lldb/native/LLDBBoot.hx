package hxcppdbg.core.drivers.lldb.native;

@:keep
@:unreflective
@:include('LLDBBoot.hpp')
@:buildXml('<include name="/mnt/d/programming/haxe/hxcppdbg/src/hxcppdbg/core/drivers/lldb/native/LLDB.xml"/>')
extern class LLDBBoot
{
    @:native('hxcppdbg::core::drivers::lldb::native::boot')
    static function boot() : Void;
}