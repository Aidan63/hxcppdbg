package hxcppdbg.dap;

import sys.thread.EventLoop;

class Signal<T>
{
    final events : EventLoop;

    final subscribers : Array<T->Void>;

    public function new(_events)
    {
        events      = _events;
        subscribers = [];
    }

    public function subscribe(_func : T->Void)
    {
        if (subscribers.indexOf(_func) == -1)
        {
            subscribers.push(_func);
        }
    }

    public function unsubscribe(_func : T->Void)
    {
        subscribers.remove(_func);
    }

    public function notify(_data : T)
    {
        for (func in subscribers)
        {
            events.run(() -> func(_data));
        }
    }
}