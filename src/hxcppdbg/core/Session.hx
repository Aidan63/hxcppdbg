package hxcppdbg.core;

import haxe.Exception;
import sys.io.File;
import json2object.JsonParser;
import hxcppdbg.core.sourcemap.Sourcemap;
import hxcppdbg.core.breakpoints.Breakpoints;
import hxcppdbg.core.breakpoints.BreakpointHit;
import hxcppdbg.core.drivers.Driver;
import hxcppdbg.core.stack.Stack;
import hxcppdbg.core.locals.Locals;

using Lambda;

class Session
{
    final parser : JsonParser<Sourcemap>;

    final driver : Driver;

    public final sourcemap : Sourcemap;

    public final breakpoints : Breakpoints;

    public final stack : Stack;

    public final locals : Locals;

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
        stack       = new Stack(sourcemap, driver.stack);
        locals      = new Locals(sourcemap, driver.locals, stack);
    }

    public function start()
    {
        driver.start();
    }

    public function resume()
    {
        driver.resume();
    }

    public function pause()
    {
        driver.pause();
    }

    public function stop()
    {
        driver.stop();
    }

    public function step(_thread : Int, _type : StepType)
    {
        final baseFrame = stack.getFrame(_thread, 0);
        
        var stepAgain = true;
        var current   = baseFrame;

        while (stepAgain)
        {
            driver.step(_thread, _type);

            stepAgain = switch (current = stack.getFrame(_thread, 0))
            {
                case Haxe(haxeCurrent, _):
                    switch baseFrame
                    {
                        case Haxe(haxeBase, _):
                            haxeCurrent.file.haxe == haxeBase.file.haxe && haxeCurrent.expr.haxe.start.line == haxeBase.expr.haxe.start.line;
                        case Native(_):
                            // Our base frame shouldn't ever be a non haxe one.
                            // In the future this might be the case (native breakpoints),
                            // so we sould correct this down the line.
                            throw new Exception('');
                    }
                case Native(_):
                    true;
            }
        }
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