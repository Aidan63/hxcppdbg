#pragma once

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

namespace hxcppdbg::core::drivers::dbgeng::native
{
    class RawFrameLocal : public hx::Object
    {
    public:
        String name;
        String type;
        String value;

        RawFrameLocal(String _name, String _type, String _value);

        void __Mark(HX_MARK_PARAMS);
#ifdef HXCPP_VISIT_ALLOCS
        void __Visit(HX_VISIT_PARAMS);
#endif
    };
}