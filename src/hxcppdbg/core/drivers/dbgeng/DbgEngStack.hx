package hxcppdbg.core.drivers.dbgeng;

import haxe.Exception;
import hxcppdbg.core.stack.NativeFrame;
import hxcppdbg.core.stack.StackFrame;
import hxcppdbg.core.drivers.dbgeng.native.RawStackFrame;
import hxcppdbg.core.drivers.dbgeng.native.DbgEngObjects;

using Lambda;
using StringTools;

class DbgEngStack implements IStack
{
    static final anonNamespace = "`anonymous namespace'::";

    final objects : DbgEngObjects;
    
	public function new(_objects)
    {
        objects = _objects;
	}

    public function getCallStack(_thread : Int)
    {
        return objects.getCallStack(_thread).map(rawFrameToNativeFrame);
    }

    private static function rawFrameToNativeFrame(_input : RawStackFrame)
    {
        // dbgeng symbol names are prefixed with the module followed by a '!' before the rest of the symbol name.
        final modulePivot   = _input.symbol.indexOf('!');
        final withoutModule = _input.symbol.substr(modulePivot + 1);

        // Here are some examples of dbgeng symbols and what I think parts of it mean...
        // There's next to no information about the ` and ' characters as they seem to be msvc internal stuff.
        //
        // sub::Resources_obj::subscribe
        // `Main_obj::main'::`2'::_hx_Closure_0::_hx_run
        // ``Main_obj::main'::`2'::_hx_Closure_1::_hx_run'::`2'::_hx_Closure_0::_hx_run(int i)
        // haxe::`anonymous namespace'::__default_trace::_hx_run(Dynamic v, Dynamic infos)
        //
        // The number of prefixed backticks refers too the number of "nameless" frames. The bottom symbol name was from
        // two nested closures which are implemented as structs defined in the function.
        // The text between the single quotes are not part of the namespace type path and the number of these quotes
        // should match the number of initial backticks.
        // What the stuff between the single quotes means I'm not sure of (number of frames which include that "frameless" code?)
        // but I also don't think we need to care.
        final count            = backtickCount(withoutModule, '`'.code);
        final buffer           = new StringBuf();
        final withoutBackticks = withoutModule.substr(count);

        var skip = false;
        var i    = 0;
        while (i < withoutBackticks.length)
        {
            switch withoutBackticks.charCodeAt(i)
            {
                case null:
                    throw new Exception('null char code');
                case "'".code:
                    skip = !skip;
                case "(".code:
                    if (buffer.toString().endsWith('operator'))
                    {
                        buffer.addChar('('.code);
                    }
                    else
                    {
                        // If we enconter an open bracket then we are at the last part of a function (its arguments) so we can skip the rest.
                        // arguments are handled based on the sourcemap, not the symbol name.
                        break;
                    }
                case '`'.code if (!skip):
                    if (withoutBackticks.substr(i, anonNamespace.length) == anonNamespace)
                    {
                        i += anonNamespace.length;

                        continue;
                    }
                case code if (!skip):
                    buffer.addChar(code);
            }

            i++;
        }

        return new NativeFrame(_input.file, buffer.toString(), _input.line);
    }

    private static function backtickCount(_input : String, _char : Int)
    {
        var count = 0;

        for (i in 0..._input.length)
        {
            if (_input.charCodeAt(i) == _char)
            {
                count++;
            }
            else
            {
                return count;
            }
        }

        return count;
    }
}