package hxcppdbg;

enum abstract Mode(String)
{
    var cli;
    var dap;
}

class Frontend
{
    @:command public var cli : Cli;
    
    public function new()
    {
        cli = new Cli();
    }

    @:defaultCommand public function help()
    {
        //
    }
}