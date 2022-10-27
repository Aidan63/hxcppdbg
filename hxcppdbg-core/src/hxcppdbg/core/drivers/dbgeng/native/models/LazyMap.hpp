#pragma once

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

#include "DbgModelClientEx.hpp"

HX_DECLARE_CLASS5(hxcppdbg, core, drivers, dbgeng, native, NativeModelData)

namespace hxcppdbg::core::drivers::dbgeng::native::models
{
    class LazyMap
    {
    private:
        Debugger::DataModel::ClientEx::Object map;

    public:
        LazyMap(const Debugger::DataModel::ClientEx::Object&);

        int count() const;
        hxcppdbg::core::drivers::dbgeng::native::NativeModelData key(const int) const;
        hxcppdbg::core::drivers::dbgeng::native::NativeModelData value(const int) const;
    };
}