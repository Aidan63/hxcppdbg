package hxcppdbg.core.drivers;

import hxcppdbg.core.ds.Result;
import haxe.Exception;
import haxe.ds.Option;

abstract class Driver
{
    public final breakpoints : IBreakpoints;

    public final stack : IStack;

    public final locals : ILocals;

    public abstract function start(_callback : Result<(Result<Option<Interrupt>, Exception>->Void)->Void, Exception>->Void) : Void;

    public abstract function stop(_callback : Option<Exception>->Void) : Void;

    public abstract function pause(_callback : Result<Bool, Exception>->Void) : Void;

    public abstract function resume(_callback : Result<(Result<Option<Interrupt>, Exception>->Void)->Void, Exception>->Void) : Void;

    public abstract function step(_thread : Int, _type : StepType, _callback : Result<(Result<Option<Interrupt>, Exception>->Void)->Void, Exception>->Void) : Void;
}