package hxcppdbg.dap;

import sys.thread.EventLoop.EventHandler;
import haxe.io.Path;
import sys.thread.Thread;
import hxcppdbg.core.Session;

class Dap
{
    var session : Null<Session>;

    var server : Null<DapServer>;

    var thread : Null<Thread>;

    var heartbeat : Null<EventHandler>;

    public var target : String;

    public var sourcemap : String;

    public function new()
    {
        session   = null;
        server    = null;
        thread    = null;
        heartbeat = null;
    }

    @:defaultCommand public function run()
    {
        session   = new Session(target, sourcemap);
        server    = new DapServer(Thread.current().events);
        thread    = Thread.createWithEventLoop(server.read);
        heartbeat = Thread.current().events.repeat(noop, 1000);
    }

    function noop()
    {
        //
    }

    function start()
    {
        switch session.start()
        {
            case Success(v):
                switch v
                {
                    case ExceptionThrown(_thread):
                        final body = {
                            reason            : 'exception',
                            threadId          : _thread,
                            allThreadsStopped : true,
                            description       : 'paused at exception'
                        }
                    case BreakpointHit(_id, _thread):
                        final body = {
                            reason            : 'breakpoint',
                            threadId          : _thread,
                            allThreadsStopped : true,
                            description       : 'paused at breakpoint',
                            hitBreakpointIds  : [ _id ]
                        }
                    case Natural:
                        //
                }
            case Error(e):
                //
        }
    }

    function resume()
    {
        //
    }

    function pause()
    {
        //
    }
}