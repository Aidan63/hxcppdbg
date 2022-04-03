package hxcppdbg.core.drivers;

enum StopReason
{
    ExceptionThrown(_thread : Int);
    BreakpointHit(_id : Int, _thread : Int);
    Natural;
}