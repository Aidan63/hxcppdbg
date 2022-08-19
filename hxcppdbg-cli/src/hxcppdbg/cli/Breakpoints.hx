package hxcppdbg.cli;

import hxcppdbg.core.ds.Path;
import tink.CoreApi.Noise;
import tink.CoreApi.Error;
import tink.CoreApi.Promise;
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

    @:defaultCommand public function help()
    {
        Sys.println(tink.Cli.getDoc(this));
    }

    @:command public function list()
    {
        final breakpoints = driver.list();

        breakpoints.sort((b1, b2) -> b1.id - b2.id);

        for (breakpoint in breakpoints)
        {
            final end = if (breakpoint.char != 0) 'Character ${ breakpoint.char }' else '';

            Sys.println('[${ breakpoint.id }] ${ breakpoint.file } Line ${ breakpoint.line } ${ end }');
        }
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

    @:defaultCommand public function run()
    {
        return Promise.irreversible((_resolve : Noise->Void, _reject : Error->Void) -> {
            driver.create(Path.of(file).normalize(), line, char, result -> {
                switch result
                {
                    case Success(bp):
                        Sys.println('Breakpoing ${ bp.id } added to ${ bp.file }:${ bp.line }');

                        _resolve(null);
                    case Error(exn):
                        _reject(new Error('Failed to add breakpoing : ${ exn.message }'));
                }
            });
        });
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

    @:defaultCommand public function run()
    {
        return Promise.irreversible((_resolve : Noise->Void, _reject : Error->Void) -> {
            driver.delete(id, error -> {
                switch error
                {
                    case Some(exn):
                        _reject(new Error('Failed to remove breakpoing $id : ${ exn.message }'));
                    case None:
                        Sys.println('Breakpoint $id removed');

                        _resolve(null);
                }
            });
        });
    }
}