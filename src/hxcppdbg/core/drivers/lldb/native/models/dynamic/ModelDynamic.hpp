#pragma once

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

#include <SBValue.h>
#include <SBTypeSummary.h>
#include <SBStream.h>

namespace hxcppdbg::core::drivers::lldb::native::models::dynamic
{
    bool setDynamicHxcppdbgModelData(::lldb::SBValue, ::lldb::SBTypeSummaryOptions, ::lldb::SBStream&);
    bool setBoxedHxcppdbgModelData(::lldb::SBValue, ::lldb::SBTypeSummaryOptions, ::lldb::SBStream&);
}