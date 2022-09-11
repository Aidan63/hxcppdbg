package hxcppdbg.core.breakpoints;

import hxcppdbg.core.ds.Path;
import haxe.Exception;
import haxe.ds.Option;
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

    public function new(_sourcemap, _driver)
    {
        sourcemap = _sourcemap;
        driver    = _driver;
        active    = [];
    }

    public function create(_hxFile : Path, _hxLine, _hxChar, _callback : Result<Breakpoint, Exception>->Void)
    {
        switch sourcemap.files.filter(f -> f.haxe.matches(_hxFile))
        {
            case []:
                _callback(Result.Error(new Exception('Unable to find file in sourcemap with name $_hxFile')));
            case files:
                switch findExpr(files, _hxLine, _hxChar)
                {
                    case Success(found):
                        driver.create(found.cpp.toString(), found.expr.cpp, result -> {
                            switch result
                            {
                                case Success(id):
                                    _callback(Result.Success(active[id] = new Breakpoint(id, found.haxe, found.expr.haxe.start.line, _hxChar, found.expr)));
                                case Error(exn):
                                    _callback(Result.Error(new Exception('Unable to set breakpoint', exn)));
                            }
                        });
                    case Error(exn):
                        _callback(Result.Error(exn));
                }
        }
    }

    public function delete(_id, _callback)
    {
        driver.remove(_id, _callback);
    }

    public function get(_id)
    {
        return switch active.get(_id)
        {
            case null:
                Option.None;
            case bp:
                Option.Some(bp);
        }
    }

    public function list()
    {
        return active.array();
    }

    function findExpr(_files : Array<GeneratedFile>, _hxLine : Int, _hxChar : Int)
    {
        final collected = [];

        for (file in _files)
        {
            for (func in file.functions)
            {
                for (closure in func.closures)
                {
                    for (e in closure.exprs.filter(expr -> _hxLine >= expr.haxe.start.line && _hxLine <= expr.haxe.end.line))
                    {
                        collected.push(e);
                    }
                }
    
                for (e in func.exprs.filter(expr -> _hxLine >= expr.haxe.start.line && _hxLine <= expr.haxe.end.line))
                {
                    collected.push(e);
                }
            }

            // I don't think there should ever be a situation where there are valid expressions in two different classes.
            // So if we have any collected expressions we can exit early.
            if (collected.length > 0)
            {
                // Sort so we can find the most specific expression at the top of the array.
                collected.sort((e1, e2) -> (e1.haxe.end.line - e1.haxe.start.line) - (e2.haxe.end.line - e2.haxe.start.line));

                return switch findInnerExpr(collected, _hxChar)
                {
                    case Some(expr):
                        Success(new ExprSearchResult(expr, file.haxe, file.cpp));
                    case None:
                        Error(new Exception('Unable to map ${ _files[0].haxe }:$_hxLine:$_hxChar'));
                }
            }
        }

        return Error(new Exception('Unable to map ${ _files[0].haxe }:$_hxLine'));
    }

    function findInnerExpr(_exprs : Array<ExprMap>, _hxChar : Int)
    {
        return if (_hxChar == 0)
        {
            Option.Some(_exprs[0]);
        }
        else
        {
            switch _exprs.filter(expr -> _hxChar >= expr.haxe.start.col && _hxChar <= expr.haxe.end.col)
            {
                case []:
                    Option.None;
                case filtered:
                    filtered.sort((e1, e2) -> e2.cpp - e1.cpp);
                    Option.Some(filtered[filtered.length - 1]);
            }
        }
    }
}

private class ExprSearchResult
{
    public final expr : ExprMap;

    public final haxe : Path;

    public final cpp : Path;

    public function new(_expr, _haxe, _cpp)
    {
        expr = _expr;
        haxe = _haxe;
        cpp  = _cpp;
    }
}