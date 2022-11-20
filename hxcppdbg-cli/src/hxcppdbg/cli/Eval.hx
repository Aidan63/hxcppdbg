package hxcppdbg.cli;

import tink.CoreApi.Error;
import tink.CoreApi.Promise;
import hxcppdbg.core.model.Printer;
import hxcppdbg.core.evaluator.Evaluator in CoreEval;

class Eval
{
    final evaluate : CoreEval;

    public var expr : String;

    public function new(_evaluate)
    {
        evaluate = _evaluate;
    }

    @:defaultCommand public function eval(_prompt : tink.cli.Prompt)
    {
        return
            Promise
                .irreversible((_resolve, _reject) -> {
                    evaluate.evaluate(expr, 0, 0, result -> {
                        switch result
                        {
                            case Success(v):
                                switch v
                                {
                                    case MEnum(type, _):
                                        _resolve('\t${ v.printType() }\t${ v.printModelData() }');
                                    case MClass(type, _):
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