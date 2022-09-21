package hxcppdbg.core;

import sys.io.File;
import sys.thread.Thread;
import haxe.Exception;
import haxe.ds.Option;
import json2object.JsonParser;
import json2object.ErrorUtils;
import hxcppdbg.core.ds.Result;
import hxcppdbg.core.sourcemap.Sourcemap;
import hxcppdbg.core.breakpoints.Breakpoints;
import hxcppdbg.core.drivers.Driver;
import hxcppdbg.core.stack.Stack;
import hxcppdbg.core.locals.Locals;
import hxcppdbg.core.thread.Threads;
import hxcppdbg.core.evaluator.Evaluator;

using Lambda;
using hxcppdbg.core.utils.ResultUtils;

class Session
{
    final driver : Driver;

    public final sourcemap : Sourcemap;

    public final breakpoints : Breakpoints;

    public final stack : Stack;

    public final locals : Locals;

    public final eval : Evaluator;

    public final threads : Threads;

    function new(_driver, _sourcemap)
    {
        driver      = _driver;
        sourcemap   = _sourcemap;
        breakpoints = new Breakpoints(sourcemap, driver.breakpoints);
        stack       = new Stack(sourcemap, driver.stack);
        locals      = new Locals(sourcemap, driver.locals, stack);
        eval        = new Evaluator(sourcemap, driver.locals, stack);
        threads     = new Threads(driver.threads);
    }

    public static function create(_targetPath, _sourcemapPath, _callback : Result<Session, Exception>->Void)
    {
        final cbThread = Thread.current();
        final parser   = new JsonParser<Sourcemap>();

        cbThread.events.promise();

        switch parser.fromJson(File.getContent(_sourcemapPath))
        {
            case null:
                cbThread.events.runPromised(() -> _callback(Result.Error(new Exception(ErrorUtils.convertErrorArray(parser.errors)))));
            case sourcemap:
#if HX_WINDOWS
                hxcppdbg.core.drivers.dbgeng.DbgEngDriver.create(
                    _targetPath,
                    sourcemap.cppEnumNames(),
                    sourcemap.cppClassNames(),
                    result -> {
                        switch result
                        {
                            case Success(driver):
                                cbThread.events.runPromised(() -> _callback(Result.Success(new Session(driver, sourcemap))));
                            case Error(exn):
                                cbThread.events.runPromised(() -> _callback(Result.Error(exn)));
                        }
                    });
#else
                hxcppdbg.core.drivers.lldb.LLDBDriver.create(_targetPath, result -> {
                    switch result
                    {
                        case Success(driver):
                            cbThread.events.runPromised(() -> _callback(Result.Success(new Session(driver, sourcemap))));
                        case Error(exn):
                            cbThread.events.runPromised(() -> _callback(Result.Error(exn)));
                    }
                });
#end
        }
    }

    public function start(_callback : Result<(Result<StopReason, Exception>->Void)->Void, Exception>->Void)
    {
        driver.start(result -> {
            switch result
            {
                case Success(run):
                    _callback(Result.Success(makeRunCallback(run)));
                case Error(exn):
                    _callback(Result.Error(exn));
            }
        });
    }

    public function resume(_callback : Result<(Result<StopReason, Exception>->Void)->Void, Exception>->Void)
    {
        driver.resume(result -> {
            switch result
            {
                case Success(run):
                    _callback(Result.Success(makeRunCallback(run)));
                case Error(exn):
                    _callback(Result.Error(exn));
            }
        });
    }

    public function pause(_result : Result<Bool, Exception>->Void)
    {
        driver.pause(_result);
    }

    public function stop(_result : Option<Exception>->Void)
    {
        driver.stop(_result);
    }

    public function step(_thread : Int, _type : StepType, _callback : Result<StopReason, Exception>->Void)
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
                                            case Success(BreakReason.Paused):
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
                                                                _callback(Result.Success(StopReason.Paused));
                                                            }
                                                        case Error(exn):
                                                            _callback(Result.Error(exn));
                                                    }
                                                });
                                            case Success(breakReason):
                                                _callback(mapBreakReason(breakReason));
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

    function makeRunCallback(_run : (Result<BreakReason, Exception>->Void)->Void)
    {
        return onStopped -> {
            _run(result -> {
                switch result
                {
                    case Success(breakReason):
                        onStopped(mapBreakReason(breakReason));
                    case Error(exn):
                        onStopped(Result.Error(exn));
                }
            });
        }
    }

    function mapBreakReason(_reason : BreakReason)
    {
        return switch _reason
        {
            case Breakpoint(threadIndex, id):
                switch breakpoints.list().find(bp -> bp.native.contains(id))
                {
                    case null:
                        Result.Error(new Exception('Unable to find breakpoing from native id $id'));
                    case bp:
                        Result.Success(StopReason.BreakpointHit(threadIndex, bp));
                }
            case Exception(threadIndex):
                Result.Success(StopReason.ExceptionThrown(threadIndex));
            case Paused:
                Result.Success(StopReason.Paused);
            case Exited(exitCode):
                Result.Success(StopReason.Exited(exitCode));
        }
    }
}