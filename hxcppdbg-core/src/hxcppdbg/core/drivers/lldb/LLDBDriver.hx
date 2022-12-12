package hxcppdbg.core.drivers.lldb;

import hxcppdbg.core.drivers.Driver.BreakReason;
import sys.thread.Thread;
import sys.thread.EventLoop.EventHandler;
import hxcppdbg.core.ds.Result;
import haxe.Exception;
import haxe.ds.Option;
import haxe.exceptions.NotImplementedException;
import hxcppdbg.core.drivers.lldb.native.LLDBContext;
import hxcppdbg.core.drivers.lldb.native.LLDBContext.LLDBStepType;

using hxcppdbg.core.utils.ResultUtils;

class LLDBDriver extends Driver
{
    final ctx : cpp.Pointer<LLDBContext>;

    final heartbeat : EventHandler;

    final cbThread : Thread;

	final dbgThread : Thread;

    function new(_ctx, _cbThread)
    {
        ctx         = _ctx;
        cbThread    = _cbThread;
        heartbeat   = Thread.current().events.repeat(noop, 1000);
        dbgThread   = Thread.current();
        breakpoints = new LLDBBreakpoints(ctx, cbThread.events);
        stack       = new LLDBStack(ctx, cbThread.events);
        locals      = new LLDBLocals(ctx, cbThread.events);
        threads     = new LLDBThreads(ctx, cbThread.events);
    }

    public static function create(_file, _callback : Result<LLDBDriver, Exception>->Void)
    {
        final cbThread = Thread.current();

        Thread.createWithEventLoop(() -> {
            final result = try
            {
                Result.Success(new LLDBDriver(LLDBContext.create(Sys.getCwd(), _file), cbThread));
            }
            catch (error : String)
            {
                Result.Error(new Exception(error));
            }

            cbThread.events.run(() -> _callback(result));
        });
    }

	public function start(_callback : Result<(Result<BreakReason, Exception>->Void)->Void, Exception>->Void) : Void
    {
        dbgThread.events.run(() -> {
            try
            {
                ctx.ptr.start();
    
                cbThread.events.run(() -> _callback(Result.Success(run)));
            }
            catch (error : String)
            {
                cbThread.events.run(() -> _callback(Result.Error(new Exception(error))));
            }
        });
    }

	public function stop(_callback : Option<Exception>->Void) : Void
    {
        throw new NotImplementedException();
    }

    public function pause(_callback : Result<Bool, Exception>->Void) : Void
    {
        try
        {
            if (ctx.ptr.interrupt(1))
            {
                dbgThread.events.run(() -> {
                    cbThread.events.run(() -> _callback(Result.Success(true)));
                });
            }
            else
            {
                _callback(Result.Success(false));
            }
        }
        catch (error : String)
        {
            _callback(Result.Error(new Exception(error)));
        }
    }

	public function resume(_callback : Result<(Result<BreakReason, Exception>->Void)->Void, Exception>->Void) : Void
    {
        dbgThread.events.run(() -> {
            try
            {
                ctx.ptr.resume();

                cbThread.events.run(() -> _callback(Result.Success(run)));
            }
            catch (error : String)
            {
                cbThread.events.run(() -> _callback(Result.Error(new Exception(error))));
            }
        });
    }

	public function step(_thread : Int, _type : StepType, _callback : Result<(Result<BreakReason, Exception>->Void)->Void, Exception>->Void) : Void
    {
        dbgThread.events.run(() -> {
            try
            {
                switch _type
                {
                    case In:
                        ctx.ptr.step(_thread, LLDBStepType.In);
                    case Over:
                        ctx.ptr.step(_thread, LLDBStepType.Over);
                    case Out:
                        ctx.ptr.step(_thread, LLDBStepType.Out);
                }

                cbThread.events.run(() -> _callback(Result.Success(run)));
            }
            catch (error : String)
            {
                cbThread.events.run(() -> _callback(Result.Error(new Exception(error))));
            }
        });
    }

    function run(_callback : Result<BreakReason, Exception>->Void)
    {
        function onException(_threadIndex)
        {
            cbThread.events.run(() -> {
                _callback(Result.Success(BreakReason.Exception(_threadIndex, Option.None)));
            });
        }

        function onBreakpoint(_threadIndex, _id)
        {
            cbThread.events.run(() -> {
                _callback(Result.Success(BreakReason.Breakpoint(_threadIndex, _id)));
            });
        }

        function onPause()
        {
            cbThread.events.run(() -> {
                _callback(Result.Success(BreakReason.Paused));
            });
        }

        function onExited(_code)
        {
            cbThread.events.run(() -> {
                _callback(Result.Success(BreakReason.Exited(_code)));
            });
        }

        dbgThread.events.run(() -> {
            ctx.ptr.wait(
                onException,
                onBreakpoint,
                onPause,
                onExited);
        });
    }

    function noop()
    {
        //
    }
}