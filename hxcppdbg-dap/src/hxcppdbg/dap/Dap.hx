package hxcppdbg.dap;

import haxe.io.Path;
import sys.thread.Thread;
import hxcppdbg.core.Session;

class Dap
{
    var debugger : Null<Session>;

    var server : Null<DapServer>;

    public var target : String;

    public var sourcemap : String;

    public function new()
    {
        debugger = null;
        server   = null;
    }

    @:defaultCommand public function run()
    {
        trace(target, sourcemap);

        debugger = new Session(target, sourcemap);
        server   = new DapServer();

        server.read();
    }
}