package hxcppdbg.core.drivers.lldb;

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

	public function start(_callback : Result<(Result<Option<Interrupt>, Exception>->Void)->Void, Exception>->Void) : Void
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
                    final result = try
                    {
                        ctx.ptr.suspend();

                        Result.Success(true);
                    }
                    catch (error : String)
                    {
                        Result.Error(new Exception(error));
                    }

                    cbThread.events.run(() -> _callback(result));
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

	public function resume(_callback : Result<(Result<Option<Interrupt>, Exception>->Void)->Void, Exception>->Void) : Void
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

	public function step(_thread : Int, _type : StepType, _callback : Result<(Result<Option<Interrupt>, Exception>->Void)->Void, Exception>->Void) : Void
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

    function run(_callback : Result<Option<Interrupt>, Exception>->Void)
    {
        dbgThread.events.run(() -> {
            ctx.ptr.wait(
                exn -> {
                    cbThread.events.run(() -> {
                        _callback(Result.Success(Option.Some(Interrupt.ExceptionThrown(Option.Some(exn)))));
                    });
                },
                (thread, bp) -> {
                    cbThread.events.run(() -> {
                        _callback(Result.Success(Option.Some(Interrupt.BreakpointHit(Option.Some(thread), Option.Some(bp.low)))));
                    });
                },
                () -> {
                    cbThread.events.run(() -> {
                        _callback(Result.Success(Option.Some(Interrupt.Other)));
                    });
                },
                () -> {
                    cbThread.events.run(() -> {
                        _callback(Result.Success(Option.None));
                    });
                });
        });
    }

    function noop()
    {
        //
    }
}