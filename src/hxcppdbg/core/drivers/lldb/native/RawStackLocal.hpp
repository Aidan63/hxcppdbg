#pragma once

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

namespace hxcppdbg::core::drivers::lldb::native
{
    class RawStackLocal : public hx::Object
    {
    public:
        String name;
        String value;
        String type;

        RawStackLocal(String _name, String _value, String _type);

        void __Mark(HX_MARK_PARAMS);
#if HXCPP_VISIT_ALLOCS
        void __Visit(HX_VISIT_PARAMS);
#endif
    };
}