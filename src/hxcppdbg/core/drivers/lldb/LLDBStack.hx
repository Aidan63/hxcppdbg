package hxcppdbg.core.drivers.lldb;

import haxe.Exception;
import hxcppdbg.core.stack.NativeFrame;
import hxcppdbg.core.drivers.lldb.native.LLDBProcess;
import hxcppdbg.core.drivers.lldb.native.RawStackFrame;

using StringTools;

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

    public function getFrame(_thread:Int, _index:Int)
    {
		return rawFrameToNativeFrame(process.getStackFrame(_thread, _index));
	}

    private static function rawFrameToNativeFrame(_input : RawStackFrame)
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