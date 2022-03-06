#include <hxcpp.h>

#include "RawStackFrame.hpp"

hxcppdbg::core::drivers::dbgeng::native::RawStackFrame::RawStackFrame(String _file, String _symbol, int _line, uint64_t _address)
    : file(_file), symbol(_symbol), line(_line), address(_address)
{
    //
}

void hxcppdbg::core::drivers::dbgeng::native::RawStackFrame::__Mark(HX_MARK_PARAMS)
{
    HX_MARK_BEGIN_CLASS(RawStackFrame);
    HX_MARK_MEMBER_NAME(file, "file");
    HX_MARK_MEMBER_NAME(symbol, "symbol");
    HX_MARK_END_CLASS();
}

#ifdef HXCPP_VISIT_ALLOCS

void hxcppdbg::core::drivers::dbgeng::native::RawStackFrame::__Visit(HX_VISIT_PARAMS)
{
    HX_VISIT_MEMBER_NAME(file, "file");
    HX_VISIT_MEMBER_NAME(symbol, "symbol");
}

#endif