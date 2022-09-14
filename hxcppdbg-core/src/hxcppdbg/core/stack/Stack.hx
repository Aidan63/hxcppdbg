package hxcppdbg.core.stack;

import haxe.Exception;
import hxcppdbg.core.ds.Result;
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

    public function getCallStack(_thread, _callback : Result<Array<StackFrame>, Exception>->Void)
    {
        driver.getCallStack(_thread, result -> {
            _callback(result.map(mapNativeFrame));
        });
    }

    public function getFrame(_thread, _index, _callback : Result<StackFrame, Exception>->Void)
    {
        driver.getFrame(_thread, _index, result -> {
            _callback(result.apply(mapNativeFrame));
        });
    }

    function mapNativeFrame(_frame : NativeFrame)
    {
        return switch sourcemap.files.find(f -> _frame.file.matches(f.cpp))
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

                // TODO : Move this into a DbgEng specific place.
                // Due to cdecl argument cleanup if a function has no args or return type the
                // line can be "off" by one.
                // See replies here for more details
                // https://stackoverflow.com/questions/42943008/visual-studio-call-stack-always-off-by-a-line

                final oneLess = _frame.line - 1;

                for (func in file.functions)
                {
                    switch func.exprs.find(expr -> expr.cpp == oneLess)
                    {
                        case null:
                            for (closure in func.closures)
                            {
                                switch closure.exprs.find(expr -> expr.cpp == oneLess)
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