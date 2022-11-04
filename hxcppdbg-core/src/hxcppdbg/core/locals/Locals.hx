package hxcppdbg.core.locals;

import haxe.Exception;
import haxe.exceptions.NotImplementedException;
import hxcppdbg.core.ds.Result;
import hxcppdbg.core.ds.FrameUID;
import hxcppdbg.core.stack.Stack;
import hxcppdbg.core.model.Keyable;
import hxcppdbg.core.cache.LocalCache;
import hxcppdbg.core.drivers.ILocals;
import hxcppdbg.core.sourcemap.Sourcemap;

using Lambda;
using hxcppdbg.core.utils.ResultUtils;

class Locals
{
    final driver : ILocals;

    final stack : Stack;

    final sourcemap : Sourcemap;

    final cache : LocalCache;

    public function new(_sourcemap, _driver, _stack, _cache)
    {
        sourcemap = _sourcemap;
        driver    = _driver;
        stack     = _stack;
        cache     = _cache;
    }

    public function getLocals(_threadIndex, _frameIndex, _callback : Result<LocalStore, Exception>->Void)
    {
        final uid = new FrameUID(_threadIndex, _frameIndex);

        switch cache[uid]
        {
            case null:
                stack.getFrame(_threadIndex, _frameIndex, result -> {
                    switch result
                    {
                        case Success(frame):
                            switch frame
                            {
                                case Haxe(haxe, _):
                                    driver.getVariables(_threadIndex, _frameIndex, result -> {
                                        switch result
                                        {
                                            case Success(store):
                                                _callback(Result.Success(cache[uid] = new LocalStore(store, haxe.func.variables)));
                                            case Error(exn):
                                                _callback(Result.Error(exn));
                                        }
                                    });
                                case Native(_):
                                    _callback(Result.Error(new Exception('Cannot get locals for native frame')));
                            }
                        case Error(exn):
                            _callback(Result.Error(exn));
                    }
                });
            case store:
                _callback(Result.Success(store));
        }
    }

    public function getArguments(_thread, _frame, _callback : Result<Keyable<String>, Exception>->Void)
    {
        _callback(Result.Error(new NotImplementedException()));

        // stack.getFrame(_thread, _frame, result -> {
        //     switch result
        //     {
        //         case Success(frame):
        //             driver.getArguments(_thread, _frame, result -> {
        //                 switch result
        //                 {
        //                     case Success(locals):
        //                         _callback(Result.Success(locals.map(mapNativeArgument.bind(frame))));
        //                     case Error(e):
        //                         _callback(Result.Error(e));
        //                 }
        //             });
        //         case Error(e):
        //             _callback(Result.Error(e));
        //     }
        // });
    }
}