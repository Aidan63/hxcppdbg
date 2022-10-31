#pragma once

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

#include "DbgModelClientEx.hpp"

HX_DECLARE_CLASS5(hxcppdbg, core, drivers, dbgeng, native, NativeModelData)

namespace hxcppdbg::core::drivers::dbgeng::native::models
{
    class LazyAnonFields
    {
    private:
        Debugger::DataModel::ClientEx::Object anon;

    public:
        LazyAnonFields(const Debugger::DataModel::ClientEx::Object&);

        int count() const;
        hxcppdbg::core::drivers::dbgeng::native::NativeModelData field(const String) const;
    };
}