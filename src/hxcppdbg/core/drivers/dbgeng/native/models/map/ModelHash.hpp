#pragma once

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

#include "models/extensions/HxcppdbgExtensionModel.hpp"
#include <experimental/generator>

HX_DECLARE_CLASS3(hxcppdbg, core, model, Model)

namespace hxcppdbg::core::drivers::dbgeng::native::models::map
{
    class ModelHash : public hxcppdbg::core::drivers::dbgeng::native::models::extensions::HxcppdbgExtensionModel
    {
    public:
        ModelHash();

        std::wstring getDisplayString(const Debugger::DataModel::ClientEx::Object& _string, const Debugger::DataModel::ClientEx::Metadata& _metadata);

        hxcppdbg::core::model::ModelData getHxcppdbgModelData(const Debugger::DataModel::ClientEx::Object& object);

        std::experimental::generator<hxcppdbg::core::model::Model> getIterator(const Debugger::DataModel::ClientEx::Object& object);
    };
}