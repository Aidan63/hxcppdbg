#include <hxcpp.h>

#include "RawStackLocal.hpp"

hxcppdbg::core::drivers::lldb::native::RawStackLocal::RawStackLocal(String _name, String _value, String _type)
    : name(_name), value(_value), type(_type)
{
    //
}

void hxcppdbg::core::drivers::lldb::native::RawStackLocal::__Mark(HX_MARK_PARAMS)
{
    HX_MARK_BEGIN_CLASS(RawStackLocal);
	HX_MARK_MEMBER_NAME(name,"name");
    HX_MARK_MEMBER_NAME(value,"value");
    HX_MARK_MEMBER_NAME(type,"type");
	HX_MARK_END_CLASS();
}

#if HXCPP_VISIT_ALLOCS

void hxcppdbg::core::drivers::lldb::native::RawStackLocal::__Visit(HX_VISIT_PARAMS)
{
    HX_VISIT_MEMBER_NAME(name,"name");
    HX_VISIT_MEMBER_NAME(value,"value");
    HX_VISIT_MEMBER_NAME(type,"type");
}

#endif