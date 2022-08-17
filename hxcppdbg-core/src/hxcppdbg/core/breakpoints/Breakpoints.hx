package hxcppdbg.core.breakpoints;

import hx.files.Path;
import haxe.Exception;
import haxe.ds.Option;
import hxcppdbg.core.ds.Signal;
import hxcppdbg.core.ds.Result;
import hxcppdbg.core.sourcemap.Sourcemap;
import hxcppdbg.core.drivers.IBreakpoints;

using Lambda;
using StringTools;
using hxcppdbg.core.utils.PathUtils;

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
        switch sourcemap.files.find(f -> f.haxe.matches(_hxFile))
        {
            case null:
                _callback(Result.Error(new Exception('Unable to find file in sourcemap with name $_hxFile')));
            case file:
                switch findExpr(file, _hxLine, _hxChar)
                {
                    case Success(mapping):
                        driver.create(file.cpp.toString(), mapping.cpp, result -> {
                            switch result
                            {
                                case Success(id):
                                    _callback(Result.Success(active[id] = new Breakpoint(id, file.haxe, mapping.haxe.start.line, _hxChar, mapping)));
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

    function findExpr(_file : GeneratedFile, _hxLine : Int, _hxChar : Int)
    {
        final collected = [];

        for (func in _file.functions)
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

        return switch collected
        {
            case []:
                Error(new Exception('Unable to map ${ _file.haxe }:$_hxLine'));
            case exprs:
                // Sort so we can find the most specific expression at the top of the array.
                exprs.sort((e1, e2) -> (e1.haxe.end.line - e1.haxe.start.line) - (e2.haxe.end.line - e2.haxe.start.line));

                switch findInnerExpr(exprs, _hxChar)
                {
                    case Some(expr):
                        Success(expr);
                    case None:
                        Error(new Exception('Unable to map ${ _file.haxe }:$_hxLine:$_hxChar'));
                }
        }
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