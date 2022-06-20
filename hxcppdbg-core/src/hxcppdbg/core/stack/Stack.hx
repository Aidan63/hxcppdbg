package hxcppdbg.core.stack;

import hxcppdbg.core.sourcemap.Sourcemap;
import hxcppdbg.core.drivers.IStack;

using Lambda;
using StringTools;
using hxcppdbg.core.utils.ResultUtils;

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
        return driver.getFrame(_thread, _index).apply(mapNativeFrame);
    }

    function mapNativeFrame(_frame : NativeFrame)
    {
        return switch sourcemap.files.find(v -> _frame.file.endsWith(v.cpp))
        {
            case null:
                StackFrame.Native(_frame);
            case file:
                for (func in file.functions)
                {
                    switch func.exprs.find(expr -> expr.cpp == _frame.line)
                    {
                        case null:
                            for (closure in func.closures)
                            {
                                switch closure.exprs.find(expr -> expr.cpp == _frame.line)
                                {
                                    case null:
                                        continue;
                                    case expr:
                                        return StackFrame.Haxe(new HaxeFrame(file, expr, func, Some(closure)), _frame);
                                }
                            }
                        case expr:
                            return StackFrame.Haxe(new HaxeFrame(file, expr, func, None), _frame);
                    }
                }

                // if we found a haxe file but could not match to an expression then we've probably hit some
                // hxcpp c++ macro code (e.g. HX_STACKFRAME generated code).
                StackFrame.Native(_frame);
        }
    }
}