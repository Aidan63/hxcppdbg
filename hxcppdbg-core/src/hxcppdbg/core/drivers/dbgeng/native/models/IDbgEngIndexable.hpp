#pragma once

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

#include "DbgModelClientEx.hpp"

HX_DECLARE_CLASS5(hxcppdbg, core, drivers, dbgeng, native, NativeModelData)

namespace hxcppdbg::core::drivers::dbgeng::native::models
{
    class IDbgEngIndexable
    {
    public:
        virtual int count() = 0;
        virtual hxcppdbg::core::drivers::dbgeng::native::NativeModelData at(const int) = 0;
    };
}