#pragma once

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

#include <optional>

#include "models/IDbgEngIndexable.hpp"

namespace hxcppdbg::core::drivers::dbgeng::native::models
{
    class LazyArray : public IDbgEngIndexable
    {
    private:
        const Debugger::DataModel::ClientEx::Object array;
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