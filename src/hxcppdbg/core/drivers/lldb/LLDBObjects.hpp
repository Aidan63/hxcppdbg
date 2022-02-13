#pragma once

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

#include <SBDebugger.h>
#include <SBTarget.h>
#include <SBBreakpointLocation.h>
#include "LLDBProcess.hpp"

namespace hxcppdbg::core::drivers::lldb
{
    class LLDBObjects : public hx::Object
    {
    public:
        LLDBObjects(::lldb::SBDebugger dbg, ::lldb::SBTarget tgt);
        
        void destroy();
        void setBreakpoint(String cppFile, int cppLine);
        hx::ObjectPtr<hxcppdbg::core::drivers::lldb::LLDBProcess> launch();

        int __GetType() const;
        String toString();

        static hx::ObjectPtr<LLDBObjects> createFromFile(String file);
    private:
        ::lldb::SBDebugger debugger;
        ::lldb::SBTarget target;

        static int lldbObjectsType;
        static void finalise(Dynamic obj);
        static bool onBreakpointHit(void *baton, ::lldb::SBProcess &process, ::lldb::SBThread &thread, ::lldb::SBBreakpointLocation &location);
    };
}