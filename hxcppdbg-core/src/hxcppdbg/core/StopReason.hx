package hxcppdbg.core;

import haxe.Int64;
import haxe.ds.Option;
import hxcppdbg.core.model.ModelData;
import hxcppdbg.core.breakpoints.Breakpoint;

enum StopReason
{
    /**
     * The debug target has been suspended and is inspectable.
     */
    Paused;

    /**
     * The debug target has hit a breakpoint and has been paused.
     * @param _threadIndex Thread index which hit the breakpoint.
     * @param _breakpoint Breakpoint which was hit by the target.
     */
    BreakpointHit(_threadIndex : Int, _breakpoint : Breakpoint);

    /**
     * The debug target has thrown an exception and has been paused.
     * @param _threadIndex Thread index which hit the breakpoint.
     * @param _thrown Object thrown.
     */
    ExceptionThrown(_threadIndex : Int, _thrown : Option<ModelData>);

    /**
     * The debug target has ended execution and returned an exit code.
     */
    Exited(_code : Int64);
}