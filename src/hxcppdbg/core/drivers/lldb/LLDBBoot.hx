package hxcppdbg.core.drivers.lldb;

@:keep
@:unreflective
@:include('LLDBBoot.hpp')
@:buildXml('<include name="/mnt/d/programming/haxe/hxcppdbg/src/hxcppdbg/core/drivers/lldb/LLDBBoot.xml"/>')
extern class LLDBBoot {
    @:native('hxcppdbg::core::drivers::lldb::boot')
    static function boot() : Void;
}