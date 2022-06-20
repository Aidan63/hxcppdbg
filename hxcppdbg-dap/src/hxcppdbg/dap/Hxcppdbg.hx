package hxcppdbg.dap;

import haxe.io.Path;
import sys.thread.Thread;
import hxcppdbg.core.Session;

class Hxcppdbg
{
    final debugger : Session;
    final server : DapServer;

    public function new()
    {
        final exe = Sys.args()[0];
        final map = Path.join([ Path.directory(exe), 'sourcemap.json' ]);

        debugger = new Session(exe, map);
        server   = new DapServer();

        server.read();
    }
}