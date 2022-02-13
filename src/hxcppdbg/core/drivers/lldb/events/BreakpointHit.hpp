#pragma once

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

namespace hxcppdbg::core::drivers::lldb::events
{
    class Frame : public hx::Object
    {
    public:
        String function;
        int line;

        Frame(String function, int line);
    };

    class BreakpointHit : public hx::Object
    {
    public:
        int breakpointID;
        int threadID;
        Array<hx::ObjectPtr<Frame>> frames;

        BreakpointHit(int breakpointID, int threadID, Array<hx::ObjectPtr<Frame>> frames);
    };
}