package hxcppdbg.cli;

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

    @:defaultCommand public function list(_prompt : tink.cli.Prompt)
    {
        return
            Promise
                .irreversible((_resolve, _reject) -> {
                    driver.getThreads(result -> {
                        switch result
                        {
                            case Success(threads):
                                final buffer = new StringBuf();

                                for (thread in threads)
                                {
                                    buffer.add('\t${ thread.name }\n');
                                }

                                _resolve(buffer.toString());
                            case Error(exn):
                                _reject(new Error(exn.message));
                        }
                    });
                })
                .next(_prompt.print);
    }
}