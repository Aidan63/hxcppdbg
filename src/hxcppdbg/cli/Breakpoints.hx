package hxcppdbg.cli;

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
        // for (id => breakpoint in breakpoints) {
        //     final end = if (breakpoint.char != 0) 'Character ${ breakpoint.char }' else '';

        //     Sys.println('[$id] ${ breakpoint.file } Line ${ breakpoint.line } ${ end }');
        // }
    }
}

class Add {
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
        switch driver.create(file, line, char)
        {
            case Success(v):
                Sys.println('Breakpoing ${ v.id } added to ${ v.file }:${ v.line }');
            case Error(e):
                Sys.println('Failed to add breakpoing : ${ e.message }');
        }
    }
}

class Remove {
    final driver : CoreBreakpoints;

    public var id : Null<Int>;

    public function new(_driver)
    {
        driver = _driver;
    }

    @:defaultCommand public function run()
    {
        if (driver.delete(id))
        {
            Sys.println('Breakpoint $id removed');
        }
        else
        {
            Sys.println('Failed to remove breakpoing $id');
        }
    }
}