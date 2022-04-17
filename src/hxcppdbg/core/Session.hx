package hxcppdbg.core;

import sys.io.File;
import haxe.Exception;
import json2object.JsonParser;
import hxcppdbg.core.ds.Result;
import hxcppdbg.core.sourcemap.Sourcemap;
import hxcppdbg.core.breakpoints.Breakpoints;
import hxcppdbg.core.breakpoints.BreakpointHit;
import hxcppdbg.core.drivers.Driver;
import hxcppdbg.core.drivers.StopReason;
import hxcppdbg.core.stack.Stack;
import hxcppdbg.core.locals.Locals;

using Lambda;
using hxcppdbg.core.utils.ResultUtils;

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
        new hxcppdbg.core.drivers.dbgeng.DbgEngDriver(_target, sourcemap.enums.map(e -> e.name.cpp));
#else
        new hxcppdbg.core.drivers.lldb.LLDBDriver(_target);
#end
        breakpoints = new Breakpoints(sourcemap, driver.breakpoints);
        stack       = new Stack(sourcemap, driver.stack);
        locals      = new Locals(sourcemap, driver.locals, stack);
    }

    public function start()
    {
        return
            driver
                .start()
                .act(dispatchStopCallbacks);
    }

    public function resume()
    {
        return
            driver
                .resume()
                .act(dispatchStopCallbacks);
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
        return switch stack.getFrame(_thread, 0)
        {
            case Success(baseFrame):
                var stepAgain = true;
                var current   = baseFrame;

                while (stepAgain)
                {
                    switch driver.step(_thread, _type)
                    {
                        case Success(Natural):
                            switch stack.getFrame(_thread, 0)
                            {
                                case Success(top):
                                    stepAgain = switch (current = top)
                                    {
                                        case Haxe(haxeCurrent, _):
                                            switch baseFrame
                                            {
                                                case Haxe(mapped, _):
                                                    haxeCurrent.file.haxe == mapped.file.haxe && haxeCurrent.expr.haxe.start.line == mapped.expr.haxe.start.line;
                                                case Native(_):
                                                    // Our base frame shouldn't ever be a non haxe one.
                                                    // In the future this might be the case (native breakpoints),
                                                    // so we sould correct this down the line.
                                                    false;
                                            }
                                        case Native(_):
                                            true;
                                    }
                                    
                                case Error(e):
                                    return Result.Error(e);
                            }
                        case Success(other):
                            dispatchStopCallbacks(other);
                            
                            return Result.Success(other);
                        case Error(e):
                            return Result.Error(e);
                    }
                }

                Result.Success(Natural);
            case Error(e):
                Result.Error(e);
        }
    }

    function dispatchStopCallbacks(_reason : StopReason)
    {
        switch _reason
        {
            case ExceptionThrown(_thread):
                breakpoints.onExceptionThrown.notify(_thread);
            case BreakpointHit(_id, _thread):
                switch breakpoints.get(_id)
                {
                    case None:
                        throw new Exception('Unable to find breakpoint with ID $_id');
                    case Some(breakpoint):
                        breakpoints.onBreakpointHit.notify(new BreakpointHit(breakpoint, _thread));
                }
            case Natural:
                //
        }
    }
}