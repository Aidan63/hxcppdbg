package hxcppdbg.core.drivers;

abstract class Driver
{
    public final breakpoints : IBreakpoints;

    public final stack : IStack;

    public final locals : ILocals;

    public abstract function start() : Void;

    public abstract function stop() : Void;

    public abstract function pause() : Void;

    public abstract function resume() : Void;

    public abstract function step(_thread : Int, _type : StepType) : Void;
}