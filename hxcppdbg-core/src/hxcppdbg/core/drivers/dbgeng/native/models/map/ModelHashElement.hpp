#pragma once

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

#include "NativeModelData.hpp"

namespace hxcppdbg::core::drivers::dbgeng::native::models::map
{
    class ModelHashElement : public Debugger::DataModel::ProviderEx::ExtensionModel
    {
    public:
        ModelHashElement(std::wstring);

        int count(const Debugger::DataModel::ClientEx::Object&, const std::optional<int>);
        hxcppdbg::core::drivers::dbgeng::native::NativeModelData at(const Debugger::DataModel::ClientEx::Object&, const int);
    };
}