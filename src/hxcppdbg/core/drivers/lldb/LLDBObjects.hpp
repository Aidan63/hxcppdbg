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
        Dynamic onBreakpointHitCallback;

        void destroy();

        hx::Null<int> setBreakpoint(String cppFile, int cppLine);
        bool removeBreakpoint(int id);

        hx::ObjectPtr<hxcppdbg::core::drivers::lldb::LLDBProcess> launch();

        void __Mark(HX_MARK_PARAMS);
#ifdef HXCPP_VISIT_ALLOCS
        void __Visit(HX_VISIT_PARAMS);
#endif
        int __GetType() const;
        String toString();

        static hx::ObjectPtr<LLDBObjects> createFromFile(String file);
    private:
        LLDBObjects(::lldb::SBDebugger dbg, ::lldb::SBTarget tgt);

        ::lldb::SBDebugger debugger;
        ::lldb::SBTarget target;

        static int lldbObjectsType;
        static void finalise(Dynamic obj);
        static bool onBreakpointHit(void *baton, ::lldb::SBProcess &process, ::lldb::SBThread &thread, ::lldb::SBBreakpointLocation &location);
    };
}