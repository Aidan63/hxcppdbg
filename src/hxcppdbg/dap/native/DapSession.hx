package hxcppdbg.dap.native;

@:keep
@:include('DapSession.hpp')
@:native('hxcppdbg::dap::native::DapSession')
@:build(hxcppdbg.core.utils.HxcppUtils.xml('DapSession'))
extern class DapSession
{
    @:native('hxcppdbg::dap::native::DapSession_obj::create')
    static function create() : DapSession;
}