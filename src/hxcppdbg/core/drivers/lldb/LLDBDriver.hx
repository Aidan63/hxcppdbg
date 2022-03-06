package hxcppdbg.core.drivers.lldb;

import hxcppdbg.core.drivers.lldb.native.LLDBBoot;
import hxcppdbg.core.drivers.lldb.native.LLDBProcess;
import hxcppdbg.core.drivers.lldb.native.LLDBObjects;

class LLDBDriver extends Driver
{
    final objects : LLDBObjects;

    final process : LLDBProcess;

    public function new(_file, _onBreakpointCb)
    {
        LLDBBoot.boot();

        objects     = LLDBObjects.createFromFile(_file);
        process     = objects.launch();
        breakpoints = new LLDBBreakpoints(objects);
        stack       = new LLDBStack(process);
        locals      = new LLDBLocals(process);

        objects.onBreakpointHitCallback = _onBreakpointCb;
    }

	public function start()
    {
        process.start(Sys.getCwd());
    }

	public function stop()
    {
        //
    }

    public function pause()
    {
        //
    }

	public function resume()
    {
        process.resume();
    }

	public function step(_thread:Int, _type:StepType)
    {
        switch _type
        {
            case In:
                process.stepIn(_thread);
            case Over:
                process.stepOver(_thread);
            case Out:
                process.stepOut(_thread);
        }
    }
}

