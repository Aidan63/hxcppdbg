#pragma once

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

#include "models/extensions/HxcppdbgExtensionModel.hpp"
#include <experimental/generator>

HX_DECLARE_CLASS3(hxcppdbg, core, model, Model)

namespace hxcppdbg::core::drivers::dbgeng::native::models::map
{
    class ModelHashElement : public hxcppdbg::core::drivers::dbgeng::native::models::extensions::HxcppdbgExtensionModel
    {
    public:
        ModelHashElement(std::wstring signature);

        std::experimental::generator<hxcppdbg::core::model::Model> getIterator(const Debugger::DataModel::ClientEx::Object& object);

        hxcppdbg::core::model::ModelData getHxcppdbgModelData(const Debugger::DataModel::ClientEx::Object& object);
    };
}