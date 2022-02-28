package hxcppdbg.core.drivers.lldb;

import haxe.Exception;
import hxcppdbg.core.drivers.lldb.LLDBProcess.Frame;
import hxcppdbg.core.stack.NativeFrame;

using Lambda;
using StringTools;

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
}

class LLDBBreakpoints implements IBreakpoints
{
    final object : LLDBObjects;

    public function new(_object)
    {
        object = _object;
    }

	public function create(_file : String, _line : Int)
    {
		return object.setBreakpoint(_file, _line);
	}

	public function remove(_id : Int)
    {
        return object.removeBreakpoint(_id);
    }
}

class LLDBStack implements IStack
{
    static final anonNamespace = '(anonymous namespace)::';

    final process : LLDBProcess;

    public function new(_process)
    {
        process = _process;
    }

	public function getCallStack(_thread) : Array<NativeFrame>
    {
		return process.getStackFrames(_thread).map(rawFrameToNativeFrame);
	}

    private static function rawFrameToNativeFrame(_input : Frame)
    {
        final buffer = new StringBuf();

        var skip = false;
        var i    = 0;
        while (i < _input.symbol.length)
        {
            switch _input.symbol.charCodeAt(i)
            {
                case null:
                    throw new Exception('null char code');
                case '('.code:
                    if (!buffer.toString().endsWith('operator'))
                    {
                        if (_input.symbol.substr(i, anonNamespace.length) == anonNamespace)
                        {
                            i += anonNamespace.length;
    
                            continue;
                        }
                        else
                        {
                            skip = true;
                        }
                    }
                    else
                    {
                        buffer.addChar('('.code);
                    }
                case ')'.code:
                    if (skip)
                    {
                        skip = false;
                    }
                    else
                    {
                        buffer.addChar(')'.code);
                    }
                case code if (!skip):
                    buffer.addChar(code);
            }

            i++;
        }

        return new NativeFrame(_input.file, buffer.toString(), _input.line);
    }
}