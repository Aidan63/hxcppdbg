#pragma once

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

#include "models/extensions/HxcppdbgExtensionModel.hpp"

namespace hxcppdbg::core::drivers::dbgeng::native::models
{
    class ModelObjectPtr : public extensions::HxcppdbgExtensionModel
    {
    public:
        ModelObjectPtr(std::wstring signature);

        Debugger::DataModel::ClientEx::Object getHxcppdbgModelData(const Debugger::DataModel::ClientEx::Object& object);
    };
}