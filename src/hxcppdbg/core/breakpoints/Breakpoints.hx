package hxcppdbg.core.breakpoints;

import haxe.Exception;
import hxcppdbg.core.ds.Signal;
import hxcppdbg.core.ds.Result;
import hxcppdbg.core.sourcemap.Sourcemap;
import hxcppdbg.core.drivers.IBreakpoints;

using Lambda;
using StringTools;

class Breakpoints
{
    final sourcemap : Sourcemap;

    final driver : IBreakpoints;

    final active : Map<Int, Breakpoint>;

    public final onBreakpointHit : Signal<BreakpointHit>;

    public function new(_sourcemap, _driver)
    {
        sourcemap       = _sourcemap;
        driver          = _driver;
        active          = [];
        onBreakpointHit = new Signal();
    }

    public function create(_hxFile, _hxLine, _hxChar = 0)
    {
        return switch sourcemap.files.find(f -> f.haxe.endsWith(_hxFile))
        {
            case null:
                Error(new Exception('Unable to find file in sourcemap with name $_hxFile'));
            case file:
                switch file.exprs.filter(expr -> _hxLine >= expr.haxe.start.line && _hxLine <= expr.haxe.end.line)
                {
                    case []:
                        Error(new Exception('unable to find a haxe expression at ${ file.haxe }:$_hxLine'));
                    case exprs:
                        final mapping = if (_hxChar == 0)
                        {
                            exprs.sort((e1, e2) -> e2.cpp - e1.cpp);
                            exprs[0];
                        }
                        else
                        {
                            switch exprs.filter(expr -> _hxChar >= expr.haxe.start.col && _hxChar <= expr.haxe.end.col)
                            {
                                case []:
                                    return Error(new Exception('unable to map $_hxFile:$_hxLine:$_hxChar to a c++ line'));
                                case filtered:
                                    filtered.sort((e1, e2) -> e2.cpp - e1.cpp);
                                    filtered[filtered.length - 1];
                            }
                        }

                        switch driver.create(file.cpp, mapping.cpp)
                        {
                            case Error(e):
                                Error(new Exception('Unable to set breakpoint', e));
                            case Success(id):
                                Success(active[id] = new Breakpoint(id, file.haxe, mapping.haxe.start.line, _hxChar, mapping));
                        }
                }
        }
    }

    public function delete(_id)
    {
        return driver.remove(_id);
    }

    public function list()
    {
        return active.array();
    }
}