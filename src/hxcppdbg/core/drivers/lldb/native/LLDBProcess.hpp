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
#include "TypeConverters.hpp"

HX_DECLARE_CLASS2(haxe, ds, Option)
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
        haxe::ds::Option start(String cwd);
        haxe::ds::Option resume();

        haxe::ds::Option stepOver(int threadIndex);
        haxe::ds::Option stepIn(int threadIndex);
        haxe::ds::Option stepOut(int threadIndex);

        hxcppdbg::core::ds::Result getStackFrame(int threadIndex, int frameIndex);
        hxcppdbg::core::ds::Result getStackFrames(int threadIndex);
        hxcppdbg::core::ds::Result getStackVariables(int threadIndex, int frameIndex);

        int __GetType() const;
        String toString();
    private:
        ::lldb::SBTarget target;
        ::lldb::SBProcess process;

        static hxcppdbg::core::stack::NativeFrame createNativeFrame(::lldb::SBFrame);
        static bool endsWith(std::string const &_input, std::string const &_ending);

        static int lldbProcessType;
        static void finalise(Dynamic obj);
    };
}