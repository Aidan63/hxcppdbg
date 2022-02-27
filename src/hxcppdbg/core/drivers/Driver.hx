package hxcppdbg.core.drivers;

abstract class Driver
{
    public final breakpoints : IBreakpoints;

    public abstract function start() : Void;

    public abstract function stop() : Void;

    public abstract function pause() : Void;

    public abstract function resume() : Void;
}