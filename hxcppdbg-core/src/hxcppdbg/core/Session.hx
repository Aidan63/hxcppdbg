package hxcppdbg.core;

import hxcppdbg.core.drivers.Interrupt;
import hxcppdbg.core.evaluator.Evaluator;
import sys.io.File;
import haxe.Exception;
import haxe.ds.Option;
import json2object.JsonParser;
import hxcppdbg.core.ds.Result;
import hxcppdbg.core.sourcemap.Sourcemap;
import hxcppdbg.core.breakpoints.Breakpoints;
import hxcppdbg.core.breakpoints.BreakpointHit;
import hxcppdbg.core.drivers.Driver;
import hxcppdbg.core.stack.Stack;
import hxcppdbg.core.locals.Locals;
import hxcppdbg.core.thread.Threads;

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

    public final threads : Threads;

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
        threads     = new Threads(driver.threads);
    }

    public function start(_callback : Result<(Result<Option<Interrupt>, Exception>->Void)->Void, Exception>->Void)
    {
        driver.start(_callback);
    }

    public function resume(_callback : Result<(Result<Option<Interrupt>, Exception>->Void)->Void, Exception>->Void)
    {
        driver.resume(_callback);
    }

    public function pause(_result : Result<Bool, Exception>->Void)
    {
        driver.pause(_result);
    }

    public function stop(_result : Option<Exception>->Void)
    {
        driver.stop(_result);
    }

    public function step(_thread : Int, _type : StepType, _callback : Result<Option<Interrupt>, Exception>->Void)
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
                                case Success(run):
                                    run(result -> {
                                        switch result
                                        {
                                            case Success(Option.None):
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
                                                                _callback(Result.Success(Option.None));
                                                            }
                                                        case Error(exn):
                                                            _callback(Result.Error(exn));
                                                    }
                                                });
                                            case Success(interrupt):
                                                _callback(Result.Success(interrupt));
                                            case Error(exn):
                                                _callback(Result.Error(exn));
                                        }
                                    });
                                case Error(exn):
                                    _callback(Result.Error(exn));
                            }
                        });
                    }

                    stepLoop();
                case Error(exn):
                    _callback(Result.Error(exn));
            }
        });
    }
}