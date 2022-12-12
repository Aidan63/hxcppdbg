package hxcppdbg.core.drivers.dbgeng.native;

import hxcppdbg.core.sourcemap.Sourcemap.GeneratedType;

typedef NameTypePair = {
    /**
     * c++ name of the type.
     */
    final name : String;

    /**
     * Type object.
     */
    final type : GeneratedType;
}

@:native('hxcppdbg::core::drivers::dbgeng::native::DbgEngContext')
@:include('DbgEngContext.hpp')
@:structAccess
#if !display
@:build(hxcppdbg.core.utils.HxcppUtils.xml('DbgEng'))
#end
extern class DbgEngContext
{
    static function get() : cpp.Pointer<DbgEngContext>;

    function start(
        _file : String,
        _classes : Array<NameTypePair>,
        _enums : Array<NameTypePair>) : cpp.Pointer<DbgEngSession>;
}
