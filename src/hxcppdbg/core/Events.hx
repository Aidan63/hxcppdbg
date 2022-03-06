package hxcppdbg.core;

class Events
{
    public final onBreakpoint : (_breakpoint : Int, _thread : Int)->Void;

	public function new(_onBreakpoint)
    {
		onBreakpoint = _onBreakpoint;
	}
}