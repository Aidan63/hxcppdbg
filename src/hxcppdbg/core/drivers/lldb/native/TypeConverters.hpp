#pragma once

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

#include <SBValue.h>
#include <SBError.h>
#include <SBStream.h>
#include <SBTypeSummary.h>

namespace hxcppdbg::core::drivers::lldb::native
{
    class TypeConverters
    {
    public:
        /**
         * Given an LLDB value which contains a HXCPP string extract the value of the string
         * and return a hxcpp string with that value.
         */
        static bool extractString(::lldb::SBValue value, ::lldb::SBTypeSummaryOptions options, ::lldb::SBStream& stream);
    };
}