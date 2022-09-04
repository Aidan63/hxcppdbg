#pragma once

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

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
        static void create(String, Dynamic, Dynamic);

        void wait(Dynamic, Dynamic, Dynamic, Dynamic);
        void interrupt(int);
        bool suspend();

        void start(String);
        void stop();
        void resume();
        void step();
    private:
        ::lldb::SBDebugger debugger;
        ::lldb::SBTarget target;
        ::lldb::SBListener listener;
        ::lldb::SBBroadcaster interruptBroadcaster;
        std::optional<::lldb::SBProcess> process;

        LLDBContext(::lldb::SBDebugger, ::lldb::SBTarget);
    };
}