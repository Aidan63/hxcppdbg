package hxcppdbg.core.breakpoints;

import tink.CoreApi.Noise;
import tink.CoreApi.Error;
import tink.CoreApi.Promise;
import haxe.Exception;
import haxe.ds.Option;
import hxcppdbg.core.ds.Path;
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

    var nextId : Int;

    public function new(_sourcemap, _driver)
    {
        sourcemap = _sourcemap;
        driver    = _driver;
        active    = [];
        nextId    = 0;
    }

    public function create(_hxFile : Path, _hxLine, _hxChar, _callback : Result<Breakpoint, Exception>->Void)
    {
        switch sourcemap.files.filter(f -> f.haxe.matches(_hxFile))
        {
            case []:
                _callback(Result.Error(new Exception('Unable to find file in sourcemap with name $_hxFile')));
            case files:
                switch findExprs(files, _hxLine, _hxChar)
                {
                    case Success(mappings):
                        Promise
                            .inSequence(mappings.flatMap(o -> [ for (expr in o.exprs) promiseCreate(o.file.cpp.toString(), expr.cpp) ]))
                            .handle(outcome -> {
                                switch outcome
                                {
                                    case Success(ids):
                                        final id = nextId++;

                                        _callback(Result.Success(active[id] = new Breakpoint(id, _hxFile, _hxLine, _hxChar, ids)));
                                    case Failure(failure):
                                        _callback(Result.Error(new Exception(failure.message)));
                                }
                            });
                    case Error(exn):
                        _callback(Result.Error(exn));
                }
        }
    }

    public function delete(_id, _callback : Option<Exception>->Void)
    {
        switch active.get(_id)
        {
            case null:
                _callback(Option.Some(new Exception('No exception found with the id $_id')));
            case bp:
                Promise
                    .inSequence(bp.native.map(promiseDelete))
                    .handle(outcome -> {
                        switch outcome
                        {
                            case Success(_):
                                if (active.remove(_id))
                                {
                                    _callback(Option.None);
                                }
                                else
                                {
                                    _callback(Option.Some(new Exception('Unable to remove breakpoint from the map')));
                                }
                            case Failure(failure):
                                _callback(Option.Some(new Exception(failure.message)));
                        }
                    });
        }
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

    function findExprs(_files : Array<GeneratedFile>, _hxLine : Int, _hxChar : Int)
    {
        final collected = [];

        function isValidExprMap(_expr : ExprMap)
        {
            return if (_hxLine >= _expr.haxe.start.line && _hxLine <= _expr.haxe.end.line)
            {
                if (_hxChar == 0)
                {
                    true;
                }
                else
                {
                    if (_hxLine == _expr.haxe.start.line)
                    {
                        _hxChar >= _expr.haxe.start.col;
                    }
                    else if (_hxLine == _expr.haxe.end.line)
                    {
                        _hxChar < _expr.haxe.end.col;
                    }
                    else
                    {
                        true;
                    }
                }
            }
            else
            {
                false;
            }
        }

        function takeMostSpecificExpr(_item : ExprMap, _result : ExprMap)
        {
            return switch _result
            {
                case null:
                    _item;
                case best:
                    final bestLineDelta  = best.haxe.end.line - best.haxe.start.line;
                    final _itemLineDelta = _item.haxe.end.line - _item.haxe.start.line;

                    if (bestLineDelta == _itemLineDelta)
                    {
                        if (best.haxe.end.col - best.haxe.start.col > _item.haxe.end.col - _item.haxe.start.col)
                        {
                            _item;
                        }
                        else
                        {
                            best;
                        }
                    }
                    else if (bestLineDelta > _itemLineDelta)
                    {
                        _item;
                    }
                    else
                    {
                        best;
                    }
            }
        }

        for (file in _files)
        {
            for (func in file.functions)
            {
                for (closure in func.closures)
                {
                    switch closure.exprs.filter(isValidExprMap)
                    {
                        case []:
                            // do nothing
                        case multiple:
                            collected.push(@:fixed { file : file, exprs : multiple });
                    }
                }

                switch func.exprs.filter(isValidExprMap)
                {
                    case []:
                        // do nothing
                    case multiple:
                        collected.push(@:fixed { file : file, exprs : multiple });
                }
            }
        }

        return switch collected
        {
            case []:
                Result.Error(new Exception('Unable to map ${ _files[0].haxe }:$_hxLine:$_hxChar'));
            case some:
                Result.Success(some);
        }
    }

    function promiseCreate(_file, _line)
    {
        return
            Promise
                .irreversible((_resolve, _reject) -> {
                    driver.create(_file, _line, result -> {
                        switch result
                        {
                            case Success(bp):
                                _resolve(bp);
                            case Error(exn):
                                _reject(new Error(exn.message));
                        }
                    });
                });
    }

    function promiseDelete(_id)
    {
        return
            Promise
                .irreversible((_resolve, _reject) -> {
                    driver.remove(_id, result -> {
                        switch result
                        {
                            case Some(exn):
                                _reject(new Error(exn.message));
                            case None:
                                _resolve((null : Noise));
                        }
                    });
                });
    }
}