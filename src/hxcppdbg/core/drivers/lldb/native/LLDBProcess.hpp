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
#include "RawStackFrame.hpp"
#include "RawStackLocal.hpp"
#include "TypeConverters.hpp"

namespace hxcppdbg::core::drivers::lldb::native
{
    class LLDBProcess : public hx::Object
    {
    public:
        LLDBProcess(::lldb::SBTarget t);
        
        void destroy();
        int getState();
        void start(String cwd);
        void resume();

        hx::ObjectPtr<hxcppdbg::core::drivers::lldb::native::RawStackFrame> stepOver(int threadIndex);
        hx::ObjectPtr<hxcppdbg::core::drivers::lldb::native::RawStackFrame> stepIn(int threadIndex);
        hx::ObjectPtr<hxcppdbg::core::drivers::lldb::native::RawStackFrame> stepOut(int threadIndex);

        hx::ObjectPtr<hxcppdbg::core::drivers::lldb::native::RawStackFrame> getStackFrame(int threadIndex, int frameIndex);
        Array<hx::ObjectPtr<hxcppdbg::core::drivers::lldb::native::RawStackFrame>> getStackFrames(int threadIndex);
        Array<hx::ObjectPtr<hxcppdbg::core::drivers::lldb::native::RawStackLocal>> getStackVariables(int threadIndex, int frameIndex);

        int __GetType() const;
        String toString();
    private:
        ::lldb::SBTarget target;
        ::lldb::SBProcess process;

        static int lldbProcessType;
        static void finalise(Dynamic obj);
    };
}