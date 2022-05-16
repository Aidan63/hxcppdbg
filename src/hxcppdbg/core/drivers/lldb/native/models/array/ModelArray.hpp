#pragma once

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

#include <SBValue.h>
#include <SBTypeSummary.h>
#include <SBStream.h>

namespace hxcppdbg::core::drivers::lldb::native::models::array
{
    bool setArrayHxcppdbgModelData(::lldb::SBValue, ::lldb::SBTypeSummaryOptions, ::lldb::SBStream&);
    bool setVirtualArrayHxcppdbgModelData(::lldb::SBValue, ::lldb::SBTypeSummaryOptions, ::lldb::SBStream&);
}