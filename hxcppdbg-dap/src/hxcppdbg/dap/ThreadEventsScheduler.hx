package hxcppdbg.dap;

import sys.thread.EventLoop;
import hxrx.schedulers.IScheduler;
import hxrx.subscriptions.Single;
import hxrx.subscriptions.Empty;
import hxrx.ISubscription;
import haxe.Timer;

class ThreadEventsScheduler implements IScheduler
{
    final events : EventLoop;

    public function new(_events)
    {
        events = _events;
    }

    public function time() return Timer.stamp();

    public function scheduleNow(_task : (_scheduler : IScheduler) -> ISubscription)
    {
        return scheduleIn(0, _task);
    }

    public function scheduleAt(_dueTime : Date, _task : (_scheduler : IScheduler) -> ISubscription)
    {
        final diff = _dueTime.getTime() - Date.now().getTime();

        return scheduleIn(diff / 1000, _task);
    }

    public function scheduleIn(_dueTime : Float, _task : (_scheduler : IScheduler) -> ISubscription)
    {
        events.run(() -> {
            _task(this);
        });

        return new Empty();
    }
}