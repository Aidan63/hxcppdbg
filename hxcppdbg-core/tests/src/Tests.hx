import buddy.SuitesRunner;
import buddy.reporting.ConsoleColorReporter;
import hxcppdbg.core.model.IndexableTests;

class Tests
{
    static function main()
    {
        final reporter = new ConsoleColorReporter();
        final runner   = new SuitesRunner([ new IndexableTests() ], reporter);

        runner
            .run()
            .then(x -> {
                if (x.failed())
                {
                    Sys.exit(-1);
                }
                else
                {
                    Sys.exit(0);
                }
            });
    }
}