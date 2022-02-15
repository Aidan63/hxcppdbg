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

namespace hxcppdbg::core::drivers::lldb
{
    class Frame : public hx::Object
    {
    public:
        String file;
        String func;
        String symbol;
        int line;

        Frame(String _file, String _func, String _symbol, int _line);

        void __Mark(HX_MARK_PARAMS);
#if HXCPP_VISIT_ALLOCS
        void __Visit(HX_VISIT_PARAMS);
#endif
    };

    class LLDBProcess : public hx::Object
    {
    public:
        LLDBProcess(::lldb::SBTarget t);
        
        void destroy();
        int getState();
        void start(String cwd);
        void resume();

        Array<hx::ObjectPtr<hxcppdbg::core::drivers::lldb::Frame>> getStackFrames(int threadID);

        int __GetType() const;
        String toString();
    private:
        ::lldb::SBTarget target;
        ::lldb::SBProcess process;

        static int lldbProcessType;
        static void finalise(Dynamic obj);
    };
}