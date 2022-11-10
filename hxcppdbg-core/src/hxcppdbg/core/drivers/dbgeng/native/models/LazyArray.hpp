#pragma once

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

#include <optional>

#include "models/IDbgEngIndexable.hpp"

HX_DECLARE_CLASS5(hxcppdbg, core, drivers, dbgeng, native, NativeModelData)

namespace hxcppdbg::core::drivers::dbgeng::native::models
{
    class LazyArray : public IDbgEngIndexable<hxcppdbg::core::drivers::dbgeng::native::NativeModelData>
    {
    private:
        std::optional<std::wstring> paramName;
        std::optional<int> paramSize;

        std::wstring getParamName();
        int getParamSize();

    public:
        LazyArray(const Debugger::DataModel::ClientEx::Object&);

        int count();
        hxcppdbg::core::drivers::dbgeng::native::NativeModelData at(const int);
    };
}