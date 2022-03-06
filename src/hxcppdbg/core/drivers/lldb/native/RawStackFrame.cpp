#include <hxcpp.h>

#include "RawStackFrame.hpp"

hxcppdbg::core::drivers::lldb::native::RawStackFrame::RawStackFrame(String _file, String _function, String _symbol, int _line)
    : file(_file), func(_function), line(_line), symbol(_symbol)
{
    //
}

void hxcppdbg::core::drivers::lldb::native::RawStackFrame::__Mark(HX_MARK_PARAMS)
{
    HX_MARK_BEGIN_CLASS(RawStackFrame);
	HX_MARK_MEMBER_NAME(file,"file");
    HX_MARK_MEMBER_NAME(func,"func");
    HX_MARK_MEMBER_NAME(symbol,"symbol");
	HX_MARK_END_CLASS();
}

#if HXCPP_VISIT_ALLOCS

void hxcppdbg::core::drivers::lldb::native::RawStackFrame::__Visit(HX_VISIT_PARAMS)
{
    HX_VISIT_MEMBER_NAME(file,"onBreakpointHitCallback");
    HX_VISIT_MEMBER_NAME(func,"func");
    HX_VISIT_MEMBER_NAME(symbol,"symbol");
}

#endif