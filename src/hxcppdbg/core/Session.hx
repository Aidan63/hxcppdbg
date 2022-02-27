package hxcppdbg.core;

import sys.io.File;
import json2object.JsonParser;
import hxcppdbg.core.sourcemap.Sourcemap;
import hxcppdbg.core.breakpoints.Breakpoints;
import hxcppdbg.core.drivers.Driver;

class Session
{
    final parser : JsonParser<Sourcemap>;

    public final driver : Driver;

    public final sourcemap : Sourcemap;

    public final breakpoints : Breakpoints;

    public function new(_target : String, _sourcemap : String)
    {
        parser      = new JsonParser<Sourcemap>();
        sourcemap   = parser.fromJson(File.getContent(_sourcemap));
        driver      =
#if HX_WINDOWS
        new hxcppdbg.core.drivers.dbgeng.DbgEngDriver(_target);
#else
        new hxcppdbg.core.drivers.lldb.LLDBDriver(_target);
#end
        breakpoints = new Breakpoints(sourcemap, driver.breakpoints);
    }
}