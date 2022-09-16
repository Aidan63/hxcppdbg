package hxcppdbg.cli;

import tink.CoreApi.Error;
import tink.CoreApi.Promise;
import hxcppdbg.core.ds.Path;
import hxcppdbg.core.breakpoints.Breakpoints in CoreBreakpoints;

using Lambda;
using StringTools;

class Breakpoints
{
    final driver : CoreBreakpoints;
    
    @:command public final add : Add;

    @:command public final remove : Remove;

    public function new(_driver)
    {
        driver = _driver;
        add    = new Add(_driver);
        remove = new Remove(_driver);
    }

    @:defaultCommand public function help(_prompt : tink.cli.Prompt)
    {
        _prompt.println(tink.Cli.getDoc(this));
    }

    @:command public function list(_prompt : tink.cli.Prompt)
    {
        final breakpoints = driver.list();
        final buffer      = new StringBuf();

        breakpoints.sort((b1, b2) -> b1.id - b2.id);

        for (breakpoint in breakpoints)
        {
            final end = if (breakpoint.char != 0) 'Character ${ breakpoint.char }' else '';

            buffer.add('[${ breakpoint.id }] ${ breakpoint.file } Line ${ breakpoint.line } ${ end }\n');
        }

        return _prompt.print(buffer.toString());
    }
}

class Add
{
    final driver : CoreBreakpoints;

    public var file : String;

    public var line : Null<Int>;

    public var char = 0;

    public function new(_driver)
    {
        driver = _driver;
    }

    @:defaultCommand public function run(_prompt : tink.cli.Prompt)
    {
        return
            Promise
                .irreversible((_resolve, _reject) -> {
                    driver.create(Path.of(file), line, char, result -> {
                        switch result
                        {
                            case Success(bp):
                                _resolve('Breakpoint ${ bp.id } added to ${ bp.file }:${ bp.line }');
                            case Error(exn):
                                _reject(new Error('Failed to add breakpoint : ${ exn.message }'));
                        }
                    });
                })
                .next(_prompt.println);
    }
}

class Remove
{
    final driver : CoreBreakpoints;

    public var id : Null<Int>;

    public function new(_driver)
    {
        driver = _driver;
    }

    @:defaultCommand public function run(_prompt : tink.cli.Prompt)
    {
        return
            Promise
                .irreversible((_resolve, _reject) -> {
                    driver.delete(id, error -> {
                        switch error
                        {
                            case Some(exn):
                                _reject(new Error('Failed to remove breakpoing $id : ${ exn.message }'));
                            case None:
                                _resolve('Breakpoint $id removed');
                        }
                    });
                })
                .next(_prompt.println);
    }
}