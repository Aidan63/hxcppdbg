#pragma once

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

#include "models/IDbgEngIndexable.hpp"

HX_DECLARE_CLASS5(hxcppdbg, core, drivers, dbgeng, native, NativeModelData)

namespace hxcppdbg::core::drivers::dbgeng::native::models
{
    class LazyEnumArguments : public IDbgEngIndexable<hxcppdbg::core::drivers::dbgeng::native::NativeModelData>
    {
    public:
        LazyEnumArguments(const Debugger::DataModel::ClientEx::Object&);

        int count();
        hxcppdbg::core::drivers::dbgeng::native::NativeModelData at(const int);
    };
}