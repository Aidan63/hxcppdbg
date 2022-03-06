#pragma once

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

namespace hxcppdbg::core::drivers::lldb::native
{
    class RawStackFrame : public hx::Object
    {
    public:
        String file;
        String func;
        String symbol;
        int line;

        RawStackFrame(String _file, String _func, String _symbol, int _line);

        void __Mark(HX_MARK_PARAMS);
#if HXCPP_VISIT_ALLOCS
        void __Visit(HX_VISIT_PARAMS);
#endif
    };
}