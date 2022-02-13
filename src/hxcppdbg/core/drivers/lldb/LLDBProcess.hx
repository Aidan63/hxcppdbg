package hxcppdbg.core.drivers.lldb;

enum abstract ProcessState(Int) {
    var eStateInvalid;
    var eStateUnloaded;  ///< Process is object is valid, but not currently loaded
    var eStateConnected; ///< Process is connected to remote debug services, but not
                     /// launched or attached to anything yet
    var eStateAttaching; ///< Process is currently trying to attach
    var eStateLaunching; ///< Process is in the process of launching
    // The state changes eStateAttaching and eStateLaunching are both sent while
    // the private state thread is either not yet started or paused. For that
    // reason, they should only be signaled as public state changes, and not
    // private state changes.
    var eStateStopped;   ///< Process or thread is stopped and can be examined.
    var eStateRunning;   ///< Process or thread is running and can't be examined.
    var eStateStepping;  ///< Process or thread is in the process of stepping and can
                     /// not be examined.
    var eStateCrashed;   ///< Process or thread has crashed and can be examined.
    var eStateDetached;  ///< Process has been detached and can't be examined.
    var eStateExited;    ///< Process has exited and can't be examined.
    var eStateSuspended; ///< Process or thread is in a suspended state as far
                     ///< as the debugger is concerned while other processes
                     ///< or threads get the chance to run.
    var kLastStateType = eStateSuspended;
}

@:keep
@:include('LLDBProcess.hpp')
@:native('hx::ObjectPtr<hxcppdbg::core::drivers::lldb::LLDBProcess>')
extern class LLDBProcess {
    function getState() : ProcessState;

    function start(cwd : String) : Void;

    function resume() : Void;

    function dump() : Void;
}