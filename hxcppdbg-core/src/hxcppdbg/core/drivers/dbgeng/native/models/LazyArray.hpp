#pragma once

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

#include "DbgModelClientEx.hpp"

HX_DECLARE_CLASS5(hxcppdbg, core, drivers, dbgeng, native, NativeModelData)

namespace hxcppdbg::core::drivers::dbgeng::native::models
{
    class LazyArray
    {
    private:
        Debugger::DataModel::ClientEx::Object array;

    public:
        LazyArray(const Debugger::DataModel::ClientEx::Object&);

        int length() const;
        int elementSize() const;
        hxcppdbg::core::drivers::dbgeng::native::NativeModelData at(const int, const int) const;
    };
}