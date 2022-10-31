#pragma once

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

#include "DbgModelClientEx.hpp"

HX_DECLARE_CLASS5(hxcppdbg, core, drivers, dbgeng, native, NativeModelData)

namespace hxcppdbg::core::drivers::dbgeng::native::models
{
    class LazyEnumArguments
    {
    private:
        Debugger::DataModel::ClientEx::Object object;

    public:
        LazyEnumArguments(const Debugger::DataModel::ClientEx::Object&);

        int count() const;
        hxcppdbg::core::drivers::dbgeng::native::NativeModelData at(const int) const;
    };
}