#pragma once

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

#include "DbgModelClientEx.hpp"

namespace hxcppdbg::core::drivers::dbgeng::native::models::enums
{
    class ModelEnumObj : public Debugger::DataModel::ProviderEx::ExtensionModel
    {
    public:
        ModelEnumObj(std::wstring signature);

        std::wstring getDisplayString(const Debugger::DataModel::ClientEx::Object& _string, const Debugger::DataModel::ClientEx::Metadata& _metadata);
    };
}