#pragma once

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

#include <SBValue.h>
#include <SBError.h>

namespace hxcppdbg::core::drivers::lldb::native
{
    /**
     * Given an LLDB value which contains a HXCPP string extract the value of the string
     * and return a hxcpp string with that value.
     */
    String extractString(::lldb::SBValue variable);
}