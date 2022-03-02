package hxcppdbg.core.stack;

import hxcppdbg.core.sourcemap.Sourcemap;
import hxcppdbg.core.drivers.IStack;

using Lambda;
using StringTools;

class Stack
{
    final driver : IStack;

    final sourcemap : Sourcemap;

    public function new(_sourcemap, _driver)
    {
        sourcemap = _sourcemap;
        driver    = _driver;
    }

    public function getCallStack(_thread)
    {
        return driver.getCallStack(_thread).map(mapNativeFrame);
    }

    public function getFrame(_thread, _index)
    {
        return mapNativeFrame(driver.getFrame(_thread, _index));
    }

    function mapNativeFrame(_frame : NativeFrame) : StackFrame
    {
        return switch sourcemap.files.find(v -> _frame.file.endsWith(v.cpp))
        {
            case null:
                StackFrame.Native(_frame);
            case file:
                switch file.exprs.find(e -> e.cpp == _frame.line)
                {
                    case null:
                        // if we found a haxe file but could not match to an expression then we've probably hit some
                        // hxcpp c++ macro code (e.g. HX_STACKFRAME generated code).
                        StackFrame.Native(_frame);
                    case expr:
                        final cppType     = _frame.func.split('::');
                        final closureName = cppType[cppType.length - 2];

                        switch cppType[cppType.length - 1]
                        {
                            case '_hx_run':
                                // _hx_run is the function name of hxcpp closures.
                                // Anonymous functions and dynamic functions are implemented as closures.
                                switch findDefinitionFunction(file, cppType)
                                {
                                    case null:
                                        // if no function was found which defines the closure then it must belong to a haxe dynamic function.
                                        // search every functions closures for our default dynamic function
                                        for (func in file.functions)
                                        {
                                            for (closure in func.closures)
                                            {
                                                return StackFrame.Haxe(new HaxeFrame(file, expr, func, Some(closure)), _frame);
                                            }
                                        }

                                        // If we can't find our closure something has gone wrong, should we throw instead?
                                        StackFrame.Native(_frame);
                                    case func:
                                        final closure = func.closures.find(f -> f.name == closureName);

                                        StackFrame.Haxe(new HaxeFrame(file, expr, func, Some(closure)), _frame);
                                }
                            case name:
                                switch file.functions.find(f -> f.cpp == name)
                                {
                                    case null:
                                        StackFrame.Native(_frame);
                                    case func:
                                        StackFrame.Haxe(new HaxeFrame(file, expr, func, None), _frame);
                                }
                        }
                }
        }
    }

    function findDefinitionFunction(_file : GeneratedFile, _cppType : Array<String>)
    {
        var i = _cppType.length - 1;
        while (i >= 0)
        {
            switch _file.functions.find(f -> f.cpp == _cppType[i])
            {
                case null:
                    //
                case found:
                    return found;
            }

            i--;
        }

        return null;
    }
}