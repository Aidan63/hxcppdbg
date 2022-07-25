package hxcppdbg.core.drivers.lldb;

import haxe.ds.Option;
import haxe.Exception;
import hxcppdbg.core.drivers.lldb.native.LLDBBoot;
import hxcppdbg.core.drivers.lldb.native.LLDBProcess;
import hxcppdbg.core.drivers.lldb.native.LLDBObjects;

using hxcppdbg.core.utils.ResultUtils;

class LLDBDriver extends Driver
{
    final objects : LLDBObjects;

    final process : LLDBProcess;

    public function new(_file)
    {
        LLDBBoot.boot();

        objects     = LLDBObjects.createFromFile(_file).resultOrThrow();
        process     = objects.launch();
        breakpoints = new LLDBBreakpoints(objects);
        stack       = new LLDBStack(process);
        locals      = new LLDBLocals(process);
    }

	public function start()
    {
        return process.start(Sys.getCwd());
    }

	public function stop()
    {
        return Option.Some(new Exception(''));
    }

    public function pause()
    {
        return process.pause();
    }

	public function resume()
    {
        return process.resume();
    }

	public function step(_thread:Int, _type:StepType)
    {
        return switch _type
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

