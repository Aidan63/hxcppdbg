#pragma once

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

#include <vector>
#include <string>
#include <iostream>
#include <SBProcess.h>
#include <SBThread.h>
#include <SBEvent.h>
#include <SBSymbol.h>
#include <SBBreakpoint.h>

HX_DECLARE_CLASS3(hxcppdbg, core, ds, Result)
HX_DECLARE_CLASS5(hxcppdbg, core, drivers, lldb, native, LLDBProcess);
HX_DECLARE_CLASS3(hxcppdbg, core, stack, NativeFrame)

namespace hxcppdbg::core::drivers::lldb::native
{
    class LLDBProcess_obj : public hx::Object
    {
    public:
        LLDBProcess_obj(::lldb::SBTarget t);
        
        int getState();
        void destroy();
        hxcppdbg::core::ds::Result start(String cwd);
        hxcppdbg::core::ds::Result resume();

        hxcppdbg::core::ds::Result stepOver(int threadIndex);
        hxcppdbg::core::ds::Result stepIn(int threadIndex);
        hxcppdbg::core::ds::Result stepOut(int threadIndex);

        hxcppdbg::core::ds::Result getStackFrame(int threadIndex, int frameIndex);
        hxcppdbg::core::ds::Result getStackFrames(int threadIndex);
        hxcppdbg::core::ds::Result getStackVariables(int threadIndex, int frameIndex);

        int __GetType() const;
        String toString();
    private:
        ::lldb::SBTarget target;
        ::lldb::SBProcess process;
        ::lldb::break_id_t exceptionBreakpoint;

        hxcppdbg::core::ds::Result findStopReason();

        static hxcppdbg::core::stack::NativeFrame createNativeFrame(::lldb::SBFrame);
        static bool endsWith(std::string const &_input, std::string const &_ending);

        static int lldbProcessType;
        static void finalise(Dynamic obj);
    };
}