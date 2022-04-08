#pragma once

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

#include "DbgModelClientEx.hpp"

namespace hxcppdbg::core::drivers::dbgeng::native::models::dynamic
{
    class ModelDynamic : public Debugger::DataModel::ProviderEx::ExtensionModel
    {
    public:
        ModelDynamic();

        std::wstring getDisplayString(const Debugger::DataModel::ClientEx::Object& object, const Debugger::DataModel::ClientEx::Metadata& metadata);
    };
}