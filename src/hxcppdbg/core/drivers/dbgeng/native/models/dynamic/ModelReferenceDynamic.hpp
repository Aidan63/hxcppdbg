#pragma once

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

#include "models/extensions/HxcppdbgExtensionModel.hpp"

namespace hxcppdbg::core::drivers::dbgeng::native::models::dynamic
{
    class ModelReferenceDynamic : public hxcppdbg::core::drivers::dbgeng::native::models::extensions::HxcppdbgExtensionModel
    {
    public:
        ModelReferenceDynamic(std::wstring signature);

        std::wstring getDisplayString(const Debugger::DataModel::ClientEx::Object& object, const Debugger::DataModel::ClientEx::Metadata& metadata);

        hxcppdbg::core::model::ModelData getHxcppdbgModelData(const Debugger::DataModel::ClientEx::Object& object);
    };
}