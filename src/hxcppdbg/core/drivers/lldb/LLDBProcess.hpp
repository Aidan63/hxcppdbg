#pragma once

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

#include <vector>
#include <string>
#include <iostream>
#include <SBProcess.h>
#include <SBThread.h>

namespace hxcppdbg::core::drivers::lldb
{
    class LLDBProcess : public hx::Object
    {
    public:
        LLDBProcess(::lldb::SBProcess p);
        
        void destroy();
        int getState();
        void resume();
        void dump();

        int __GetType() const;
        String toString();
    private:
        ::lldb::SBProcess process;

        static int lldbProcessType;
        static void finalise(Dynamic obj);
    };
}