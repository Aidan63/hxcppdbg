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

    /**
     * Create a breakpoint at the given location.
     * @param _hxFile Path of the haxe file to create the breakpoint in.
     * @param _hxLine Line within the haxe file to create the breakpoint at.
     * @param _hxChar 1 based character offset for finding the most specific haxe expression in a line
     * If 0 is provided breakpoints are created at all valid expressions within the line.
     * @param _callback Function called when the create operation has succeeded or failed.
     */
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
                                        final id   = nextId++;
                                        final file = mappings[0].file.haxe;

                                        _callback(Result.Success(active[id] = new Breakpoint(id, file, _hxLine, _hxChar, ids)));
                                    case Failure(failure):
                                        _callback(Result.Error(new Exception(failure.message)));
                                }
                            });
                    case Error(exn):
                        _callback(Result.Error(exn));
                }
        }
    }

    /**
     * Delete a breakpoint.
     * @param _id ID of the breakpoint to delete.
     * @param _callback Function called when the delete operation has succeeded or failed.
     */
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

    /**
     * Get the breakpoint object from a given ID.
     * @param _id ID of the breakpoint to get.
     */
    public function get(_id)
    {
        return switch active.get(_id)
        {
            case null:
                Option.None;
            case bp:
                Option.Some((bp : Breakpoint));
        }
    }

    /**
     * Return an array of all breakpoint objects.
     */
    public function list()
    {
        return active.array();
    }

    function findExprs(_files : Array<GeneratedFile>, _hxLine : Int, _hxChar : Int)
    {
        final collected = [];

        /**
         * Given an expression range returns if the expression falls within the current line and character constraints.
         * @param _range Haxe expression to check.
         */
        function isValidExprRange(_range : ExprRange)
        {
            return if (_hxLine >= _range.start.line && _hxLine <= _range.end.line)
            {
                if (_hxChar == 0)
                {
                    true;
                }
                else
                {
                    if (_hxLine == _range.start.line)
                    {
                        _hxChar >= _range.start.col;
                    }
                    else if (_hxLine == _range.end.line)
                    {
                        _hxChar < _range.end.col;
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

        /**
         * Given an expression mapping returns if its valid with the `fundExprs` constraints.
         * @param _expr Expression map to check.
         */
        function isValidExprMap(_expr : ExprMap)
        {
            return isValidExprRange(_expr.haxe);
        }

        /**
         * Given two expression ranges return the most specific range given the line and character constraints.
         * If `_results` is null `_item` is returned. This function can be used with `Lambda.fold`
         * @param _item New expression range to check.
         * @param _result Current most specific expression range.
         */
        function takeMostSpecificExpr(_item : ExprRange, _result : ExprRange)
        {
            return switch _result
            {
                case null:
                    _item;
                case best:
                    final bestLineDelta  = best.end.line - best.start.line;
                    final _itemLineDelta = _item.end.line - _item.start.line;

                    if (bestLineDelta == _itemLineDelta)
                    {
                        if (best.end.col - best.start.col > _item.end.col - _item.start.col)
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

    /**
     * Return a tink promise around creating a native breakpoint.
     * @param _file C++ file to create the breakpoint in.
     * @param _line Line to create the breakpoint at.
     */
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

    /**
     * Return a tink promise around deleting a native breakpoint.
     * @param _id ID of the native breakpoint to remove.
     */
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