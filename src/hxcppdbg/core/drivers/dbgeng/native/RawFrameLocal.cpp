#include <hxcpp.h>

#include "RawFrameLocal.hpp"

hxcppdbg::core::drivers::dbgeng::native::RawFrameLocal::RawFrameLocal(String _name, String _type, String _value)
    : name(_name), type(_type), value(_value)
{
    //
}

void hxcppdbg::core::drivers::dbgeng::native::RawFrameLocal::__Mark(HX_MARK_PARAMS)
{
    HX_MARK_BEGIN_CLASS(RawStrackFrame);
    HX_MARK_MEMBER_NAME(name, "name");
    HX_MARK_MEMBER_NAME(type, "type");
    HX_MARK_MEMBER_NAME(value, "value");
    HX_MARK_END_CLASS();
}

#ifdef HXCPP_VISIT_ALLOCS

void hxcppdbg::core::drivers::dbgeng::native::RawFrameLocal::__Visit(HX_VISIT_PARAMS)
{
    HX_VISIT_MEMBER_NAME(name, "name");
    HX_VISIT_MEMBER_NAME(type, "type");
    HX_VISIT_MEMBER_NAME(value, "value");
}

#endif