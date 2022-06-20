package hxcppdbg.core.breakpoints;

class BreakpointHit
{
    public final breakpoint : Breakpoint;

    public final thread : Int;

	public function new(_breakpoint, _thread)
    {
		breakpoint = _breakpoint;
		thread     = _thread;
	}
}