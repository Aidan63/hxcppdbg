#pragma once

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

#include <optional>
#include "models/IDbgEngIndexable.hpp"

HX_DECLARE_CLASS5(hxcppdbg, core, drivers, dbgeng, native, NativeModelData)

namespace hxcppdbg::core::drivers::dbgeng::native::models
{
    class LazyNativeArray : public IDbgEngIndexable<hxcppdbg::core::drivers::dbgeng::native::NativeModelData>
    {
    private:
        const std::wstring type;
        const int size;
    public:
        LazyNativeArray(const Debugger::DataModel::ClientEx::Object&, const int&);

        int count();
        hxcppdbg::core::drivers::dbgeng::native::NativeModelData at(const int);
    };
}