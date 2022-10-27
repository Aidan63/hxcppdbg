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
        cpp::Reference<Debugger::DataModel::ClientEx::Object> map;

    public:
        LazyMap(const Debugger::DataModel::ClientEx::Object&);

        int count() const;
        hxcppdbg::core::drivers::dbgeng::native::NativeModelData child(const int) const;
    };
}