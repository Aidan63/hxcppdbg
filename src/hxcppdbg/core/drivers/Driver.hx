package hxcppdbg.core.drivers;

import haxe.Exception;
import haxe.ds.Option;

abstract class Driver
{
    public final breakpoints : IBreakpoints;

    public final stack : IStack;

    public final locals : ILocals;

    public abstract function start() : Option<Exception>;

    public abstract function stop() : Option<Exception>;

    public abstract function pause() : Option<Exception>;

    public abstract function resume() : Option<Exception>;

    public abstract function step(_thread : Int, _type : StepType) : Option<Exception>;
}