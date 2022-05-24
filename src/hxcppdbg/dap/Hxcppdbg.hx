package hxcppdbg.dap;

import hxcppdbg.dap.native.DapSession;
import sys.thread.Thread;
import hxcppdbg.core.Session;

class Hxcppdbg
{
    final debugger : Session;

    final dap : DapSession;

    public function new()
    {
        final args = Sys.args();

        debugger = new Session(args[0], args[1]);
        dap      = DapSession.create();
    }
}