#pragma once

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

#include "DbgModelClientEx.hpp"

namespace hxcppdbg::core::drivers::dbgeng::native::models::array
{
    class ModelVirtualArrayObj : public Debugger::DataModel::ProviderEx::ExtensionModel
    {
    public:
        ModelVirtualArrayObj();

        std::wstring getDisplayString(const Debugger::DataModel::ClientEx::Object& _string, const Debugger::DataModel::ClientEx::Metadata& _metadata);
    };
}