package hxcppdbg.core.drivers.lldb;

import hxcppdbg.core.ds.Lazy;
import sys.thread.Thread;
import sys.thread.EventLoop.EventHandler;
import hxcppdbg.core.ds.Result;
import haxe.Exception;
import haxe.ds.Option;
import haxe.exceptions.NotImplementedException;
import hxcppdbg.core.drivers.lldb.native.LLDBBoot;
import hxcppdbg.core.drivers.lldb.native.LLDBContext;
import hxcppdbg.core.drivers.lldb.native.LLDBContext.LLDBStepType;

using hxcppdbg.core.utils.ResultUtils;

class LLDBDriver extends Driver
{
    var ctx : cpp.Pointer<LLDBContext>;

    var heartbeat : Null<EventHandler>;

    final cbThread : Thread;

	final dbgThread : Thread;

    // final objects : LLDBObjects;

    // final process : LLDBProcess;

    public function new(_file)
    {
        // LLDBBoot.boot();

        ctx       = null;
        heartbeat = null;
        cbThread  = Thread.current();
        dbgThread = Thread.createWithEventLoop(() -> {
            LLDBBoot.boot();
            LLDBContext.create(
                _file,
                _ptr -> {
                    ctx = _ptr;
                },
                _err -> {
                    throw new Exception(_err);
                });

            heartbeat = Thread.current().events.repeat(noop, 1000);
        });

        final lazy = new Lazy(() -> ctx);

        breakpoints = new LLDBBreakpoints(lazy, dbgThread.events, cbThread.events);
        stack       = new LLDBStack(lazy, dbgThread.events, cbThread.events);
        // locals      = new LLDBLocals(process);
    }

	public function start(_callback : Result<(Result<Option<Interrupt>, Exception>->Void)->Void, Exception>->Void) : Void
    {
        dbgThread.events.run(() -> {
            try
            {
                ctx.ptr.start(Sys.getCwd());
    
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
        ctx.ptr.interrupt(1);

        dbgThread.events.run(() -> {
            final result = try
            {
                if (ctx.ptr.suspend())
                {
                    Result.Success(false);
                }
                else
                {
                    Result.Success(true);
                }
            }
            catch (error : String)
            {
                Result.Error(new Exception(error));
            }

            cbThread.events.run(() -> _callback(result));
        });
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