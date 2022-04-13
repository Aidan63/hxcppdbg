#pragma once

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

#include "models/extensions/HxcppdbgExtensionModel.hpp"

namespace hxcppdbg::core::drivers::dbgeng::native::models::map
{
    class ModelMapObj : public hxcppdbg::core::drivers::dbgeng::native::models::extensions::HxcppdbgExtensionModel
    {
    public:
        ModelMapObj(std::wstring signature);

        std::wstring getDisplayString(const Debugger::DataModel::ClientEx::Object& _string, const Debugger::DataModel::ClientEx::Metadata& _metadata);

        hxcppdbg::core::model::ModelData getHxcppdbgModelData(const Debugger::DataModel::ClientEx::Object& object);
    };
}