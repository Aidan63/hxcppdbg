package hxcppdbg.core.drivers;

import haxe.Int64;
import haxe.Exception;
import haxe.ds.Option;
import hxcppdbg.core.ds.Result;

enum BreakReason
{
    Breakpoint(threadIndex : Int, id : Int64);
    Exception(threadIndex : Int);
    Paused;
    Exited(exitCode : Int64);
}

abstract class Driver
{
    public final breakpoints : IBreakpoints;

    public final stack : IStack;

    public final locals : ILocals;

    public final threads : IThreads;

    public abstract function start(_callback : Result<(Result<BreakReason, Exception>->Void)->Void, Exception>->Void) : Void;

    public abstract function stop(_callback : Option<Exception>->Void) : Void;

    public abstract function pause(_callback : Result<Bool, Exception>->Void) : Void;

    public abstract function resume(_callback : Result<(Result<BreakReason, Exception>->Void)->Void, Exception>->Void) : Void;

    public abstract function step(_thread : Int, _type : StepType, _callback : Result<(Result<BreakReason, Exception>->Void)->Void, Exception>->Void) : Void;
}