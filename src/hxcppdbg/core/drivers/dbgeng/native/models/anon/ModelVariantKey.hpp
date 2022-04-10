#pragma once

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

#include "DbgModelClientEx.hpp"

namespace hxcppdbg::core::drivers::dbgeng::native::models::anon
{
    class ModelVariantKey : public Debugger::DataModel::ProviderEx::ExtensionModel
    {
    public:
        ModelVariantKey();

        std::wstring getDisplayString(const Debugger::DataModel::ClientEx::Object& object, const Debugger::DataModel::ClientEx::Metadata& metadata);
    };
}