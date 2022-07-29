package hxcppdbg.core;

import tink.core.Option;
import hxcppdbg.core.evaluator.Evaluator;
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

    public final eval : Evaluator;

    public function new(_target : String, _sourcemap : String)
    {
        parser      = new JsonParser<Sourcemap>();
        sourcemap   = parser.fromJson(File.getContent(_sourcemap));
        driver      =
#if HX_WINDOWS
        new hxcppdbg.core.drivers.dbgeng.DbgEngDriver(_target, sourcemap.cppEnumNames(), sourcemap.cppClassNames());
#else
        new hxcppdbg.core.drivers.lldb.LLDBDriver(_target);
#end
        breakpoints = new Breakpoints(sourcemap, driver.breakpoints);
        stack       = new Stack(sourcemap, driver.stack);
        locals      = new Locals(sourcemap, driver.locals, stack);
        eval        = new Evaluator(sourcemap, driver.locals, stack);
    }

    public function start(_result : Option<Exception>->Void)
    {
        driver.start(_result);
    }

    public function resume(_result : Option<Exception>->Void)
    {
        return driver.resume(_result);
    }

    public function pause(_result : Option<Exception>->Void)
    {
        driver.pause(_result);
    }

    public function stop(_result : Option<Exception>->Void)
    {
        driver.stop(_result);
    }

    public function step(_thread : Int, _type : StepType, _result : Option<Exception>->Void)
    {
        stack.getFrame(_thread, 0, result -> {
            switch result
            {
                case Success(baseFrame):
                    var current = baseFrame;

                    function stepLoop()
                    {
                        driver.step(_thread, _type, result -> {
                            switch result
                            {
                                case Some(exn):
                                    _result(Option.Some(exn));
                                case None:
                                    stack.getFrame(_thread, 0, result -> {
                                        switch result
                                        {
                                            case Success(top):
                                                final again = switch (current = top)
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

                                                if (again)
                                                {
                                                    stepLoop();
                                                }
                                                else
                                                {
                                                    _result(Option.None);
                                                }
                                            case Error(exn):
                                                _result(Option.Some(exn));
                                        }
                                    });
                            }
                        });
                    }

                    stepLoop();
                case Error(e):
                    _result(Option.Some(e));
            }
        });
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
            case _:
                //
        }
    }
}