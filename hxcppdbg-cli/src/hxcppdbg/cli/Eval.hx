package hxcppdbg.cli;

import tink.CoreApi.Noise;
import tink.CoreApi.Error;
import tink.CoreApi.Promise;
import hxcppdbg.core.evaluator.Evaluator in CoreEval;
import hxcppdbg.core.model.Printer;

class Eval
{
    final evaluate : CoreEval;

    public var expr : String;

    public function new(_evaluate)
    {
        evaluate = _evaluate;
    }

    @:defaultCommand public function eval()
    {
        return Promise.irreversible((_resolve : Noise->Void, _reject : Error->Void) -> {
            evaluate.evaluate(expr, 0, 0, result -> {
                switch result
                {
                    case Success(v):
                        switch v
                        {
                            case MEnum(type, _):
                                Sys.println('\t${ printType(type) }\t${ printModelData(v) }');
                            case MClass(type, _):
                                Sys.println('\t${ printType(type) }\t${ printModelData(v) }');
                            case _:
                                Sys.println('\t${ printModelData(v) }');
                        }

                        _resolve(null);
                    case Error(exn):
                        _reject(new Error('\tError : ${ exn.message }'));
                }
            });
        });
    }
}