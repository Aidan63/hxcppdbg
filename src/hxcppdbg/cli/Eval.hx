package hxcppdbg.cli;

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
        switch evaluate.evaluate(expr, 0, 0)
        {
            case Success(v):
                Sys.println('\t${ printModelData(v) }');
            case Error(e):
                Sys.println('\tError : ${ e.message }');
        }
    }
}