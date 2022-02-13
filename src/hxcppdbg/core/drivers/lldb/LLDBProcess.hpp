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

namespace hxcppdbg::core::drivers::lldb
{
    class LLDBProcess : public hx::Object
    {
    public:
        LLDBProcess(::lldb::SBTarget t);
        
        void destroy();
        int getState();
        void start(String cwd);
        void resume();
        void dump();

        int __GetType() const;
        String toString();
    private:
        ::lldb::SBTarget target;
        ::lldb::SBProcess process;

        static int lldbProcessType;
        static void finalise(Dynamic obj);
    };
}