package hxcppdbg.cli;

import tink.CoreApi.Noise;
import tink.CoreApi.Error;
import tink.CoreApi.Promise;
import hxcppdbg.core.thread.Threads in CoreThreads;

class Threads
{
    final driver : CoreThreads;

    public function new(_driver)
    {
        driver = _driver;
    }

    @:defaultCommand
    public function list()
    {
        return Promise.irreversible((_resolve : Noise->Void, _reject : Error->Void) -> {
            driver.getThreads(result -> {
                switch result
                {
                    case Success(threads):
                        for (thread in threads)
                        {
                            Sys.println('\t${ thread.name }');
                        }
                        _resolve(null);
                    case Error(exn):
                        _reject(new Error(exn.message));
                }
            });
        });
    }
}