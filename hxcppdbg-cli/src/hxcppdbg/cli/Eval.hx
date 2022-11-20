package hxcppdbg.cli;

import haxe.Exception;
import hxcppdbg.core.ds.Result;
import hxcppdbg.core.StopReason;
import tink.CoreApi.Error;
import tink.CoreApi.Promise;
import hxcppdbg.core.evaluator.Evaluator in CoreEval;

class Eval
{
    final evaluate : CoreEval;

    final stopReason : Result<StopReason, Exception>;

    public var expr : String;

    public var thread = 0;

    public var frame = 0;

    public function new(_evaluate, _stopReason)
    {
        evaluate   = _evaluate;
        stopReason = _stopReason;
    }

    @:defaultCommand public function eval(_prompt : tink.cli.Prompt)
    {
        return
            Promise
                .irreversible((_resolve, _reject) -> {
                    evaluate.evaluate(expr, thread, frame, stopReason, result -> {
                        switch result
                        {
                            case Success(v):
                                switch v
                                {
                                    case MEnum(_, _):
                                        _resolve('\t${ v.printType() }\t${ v.printModelData() }');
                                    case MClass(_, _):
                                        _resolve('\t${ v.printType() }\t${ v.printModelData() }');
                                    case _:
                                        _resolve('\t${ v.printModelData() }');
                                }
                            case Error(exn):
                                _reject(new Error('\tError : ${ exn.message }'));
                        }
                    });
                })
                .next(_prompt.println);
    }
}