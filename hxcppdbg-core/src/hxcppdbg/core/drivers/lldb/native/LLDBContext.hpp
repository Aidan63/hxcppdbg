#pragma once

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

#include <cpp/Int64.h>

#include <optional>

#include <lldb/API/SBEvent.h>
#include <lldb/API/SBTarget.h>
#include <lldb/API/SBThread.h>
#include <lldb/API/SBProcess.h>
#include <lldb/API/SBDebugger.h>
#include <lldb/API/SBListener.h>
#include <lldb/API/SBBroadcaster.h>
#include <lldb/API/SBBreakpointLocation.h>

namespace hxcppdbg::core::drivers::lldb::native
{
    enum InterruptEvent
    {
        Pause   = (1u << 0),
        Stop    = (1u << 1),
        Restart = (1u << 2)
    };

    class LLDBContext
    {
    public:
        static cpp::Pointer<LLDBContext> create(String, String);

        void wait(Dynamic, Dynamic, Dynamic, Dynamic);
        bool interrupt(int);
        void suspend();

        void start();
        void stop();
        void resume();
        void step(int, int);

        int64_t createBreakpoint(String, int);
        bool removeBreakpoint(int64_t);

        hx::Anon getStackFrame(int, int);
        Array<hx::Anon> getStackFrames(int);

        Array<hx::Anon> getThreads();

        Array<hx::Anon> getLocals(int, int);
        Array<hx::Anon> getArguments(int, int);
    private:
        ::lldb::SBDebugger debugger;
        ::lldb::SBTarget target;
        ::lldb::SBListener listener;
        ::lldb::SBBroadcaster interruptBroadcaster;
        ::lldb::SBBreakpoint exceptionBreakpoint;
        ::lldb::SBProcess process;

        LLDBContext(::lldb::SBDebugger, ::lldb::SBTarget, ::lldb::SBProcess);

        bool endsWith(std::string const &, std::string const &);
    };
}