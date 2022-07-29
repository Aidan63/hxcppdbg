package hxcppdbg.core.drivers;

import haxe.Exception;
import haxe.ds.Option;

abstract class Driver
{
    public final breakpoints : IBreakpoints;

    public final stack : IStack;

    public final locals : ILocals;

    public abstract function start(_result : Option<Exception>->Void) : Void;

    public abstract function stop(_result : Option<Exception>->Void) : Void;

    public abstract function pause(_result : Option<Exception>->Void) : Void;

    public abstract function resume(_result : Option<Exception>->Void) : Void;

    public abstract function step(_thread : Int, _type : StepType, _result : Option<Exception>->Void) : Void;
}