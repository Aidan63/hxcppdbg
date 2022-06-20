#pragma once

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

#include <SBDebugger.h>
#include <SBTarget.h>
#include <SBBreakpointLocation.h>

HX_DECLARE_CLASS2(haxe, ds, Option)
HX_DECLARE_CLASS3(hxcppdbg, core, ds, Result)
HX_DECLARE_CLASS5(hxcppdbg, core, drivers, lldb, native, LLDBObjects)
HX_DECLARE_CLASS5(hxcppdbg, core, drivers, lldb, native, LLDBProcess)

namespace hxcppdbg::core::drivers::lldb::native
{
    class LLDBObjects_obj : public hx::Object
    {
    public:
        Dynamic onBreakpointHitCallback;

        void destroy();

        hxcppdbg::core::ds::Result setBreakpoint(String cppFile, int cppLine);
        haxe::ds::Option removeBreakpoint(int id);

        hxcppdbg::core::drivers::lldb::native::LLDBProcess launch();

        void __Mark(HX_MARK_PARAMS);
#ifdef HXCPP_VISIT_ALLOCS
        void __Visit(HX_VISIT_PARAMS);
#endif
        int __GetType() const;
        String toString();

        static hxcppdbg::core::ds::Result createFromFile(String file);
    private:
        LLDBObjects_obj(::lldb::SBDebugger dbg, ::lldb::SBTarget tgt);

        ::lldb::SBDebugger debugger;
        ::lldb::SBTarget target;

        static int lldbObjectsType;
        static void finalise(Dynamic obj);
        static bool onBreakpointHit(void *baton, ::lldb::SBProcess &process, ::lldb::SBThread &thread, ::lldb::SBBreakpointLocation &location);
    };
}