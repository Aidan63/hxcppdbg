package hxcppdbg.core;

import hxcppdbg.core.stack.Stack;
import haxe.Exception;
import sys.io.File;
import json2object.JsonParser;
import hxcppdbg.core.sourcemap.Sourcemap;
import hxcppdbg.core.breakpoints.Breakpoints;
import hxcppdbg.core.breakpoints.BreakpointHit;
import hxcppdbg.core.drivers.Driver;

using Lambda;

class Session
{
    final parser : JsonParser<Sourcemap>;

    public final driver : Driver;

    public final sourcemap : Sourcemap;

    public final breakpoints : Breakpoints;

    public final stack : Stack;

    public function new(_target : String, _sourcemap : String)
    {
        parser      = new JsonParser<Sourcemap>();
        sourcemap   = parser.fromJson(File.getContent(_sourcemap));
        driver      =
#if HX_WINDOWS
        new hxcppdbg.core.drivers.dbgeng.DbgEngDriver(_target, onNativeBreakpointHit);
#else
        new hxcppdbg.core.drivers.lldb.LLDBDriver(_target, onNativeBreakpointHit);
#end
        breakpoints = new Breakpoints(sourcemap, driver.breakpoints);
        stack       = new Stack(driver.stack);
    }

    /**
     * This function is invoked by the driver whenever a native breakpoint is hit.
     * We then attempt to map that native breakpoint onto a haxe one and emit an event.
     * @param _breakpointID Native driver specific breakpoint ID.
     * @param _threadID Native driver specific thread ID.
     */
    function onNativeBreakpointHit(_breakpointID : Int, _threadID : Int)
    {
        switch breakpoints.list().find(bp -> bp.id == _breakpointID)
        {
            case null:
                throw new Exception('Unable to find breakpoint with ID $_breakpointID');
            case breakpoint:
                breakpoints.onBreakpointHit.notify(new BreakpointHit(breakpoint, _threadID));
        }
    }
}