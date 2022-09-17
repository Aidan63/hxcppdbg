#pragma once

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

#include <cpp/Int64.h>

#include <optional>

#include <SBEvent.h>
#include <SBTarget.h>
#include <SBThread.h>
#include <SBProcess.h>
#include <SBDebugger.h>
#include <SBListener.h>
#include <SBBroadcaster.h>
#include <SBBreakpointLocation.h>

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

        cpp::Int64Struct createBreakpoint(String, int);
        bool removeBreakpoint(cpp::Int64Struct);

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