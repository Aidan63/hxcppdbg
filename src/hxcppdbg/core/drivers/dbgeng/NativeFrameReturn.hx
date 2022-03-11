package hxcppdbg.core.drivers.dbgeng;

import hxcppdbg.core.stack.NativeFrame;

class NativeFrameReturn
{
    public final frame : NativeFrame;

    public final address : cpp.UInt64;

	public function new(_frame, _address)
    {
		frame   = _frame;
		address = _address;
	}
}