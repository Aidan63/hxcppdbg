#pragma once

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

namespace hxcppdbg::core::drivers::dbgeng::native
{
    class RawStackFrame : public hx::Object
    {
    public:
        String file;
        String symbol;
        int line;

        RawStackFrame(String _file, String _symbol, int _line);

        void __Mark(HX_MARK_PARAMS);
#ifdef HXCPP_VISIT_ALLOCS
        void __Visit(HX_VISIT_PARAMS);
#endif
    };
}