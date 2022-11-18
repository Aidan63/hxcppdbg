#pragma once

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

#include "DbgModelClientEx.hpp"
#include "NativeModelData.hpp"

namespace hxcppdbg::core::drivers::dbgeng::native::models::extensions
{
    class HxcppdbgExtensionModel : public Debugger::DataModel::ProviderEx::ExtensionModel
    {
    public:
        HxcppdbgExtensionModel(std::wstring signature);
        HxcppdbgExtensionModel(const char16_t* signature);

        virtual Debugger::DataModel::ClientEx::Object getHxcppdbgModelData(const Debugger::DataModel::ClientEx::Object&) = 0;
    };
}
