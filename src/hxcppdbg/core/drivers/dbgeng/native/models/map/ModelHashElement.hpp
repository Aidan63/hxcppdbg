#pragma once

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

#include "models/extensions/HxcppdbgExtensionModel.hpp"
#include <experimental/generator>

HX_DECLARE_CLASS3(hxcppdbg, core, model, Model)

namespace hxcppdbg::core::drivers::dbgeng::native::models::map
{
    class ModelHashElement : public Debugger::DataModel::ProviderEx::ExtensionModel
    {
    public:
        ModelHashElement(std::wstring signature);

        std::wstring getDisplayString(const Debugger::DataModel::ClientEx::Object& object, const Debugger::DataModel::ClientEx::Metadata& metadata);

        std::experimental::generator<hxcppdbg::core::model::Model> getIterator(const Debugger::DataModel::ClientEx::Object& object);
    };
}