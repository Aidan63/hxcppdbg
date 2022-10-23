#pragma once

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

#include "models/extensions/HxcppdbgModelFactory.hpp"

HX_DECLARE_CLASS3(hxcppdbg, core, model, Model)

namespace Debugger::DataModel::ClientEx::Boxing
{
    template<>
    struct BoxObject<hxcppdbg::core::model::Model>
    {
        static Object Box(const hxcppdbg::core::model::Model& model)
        {
            return hxcppdbg::core::drivers::dbgeng::native::models::extensions::HxcppdbgModelFactory::instance->CreateInstance(model);
        }

        static hxcppdbg::core::model::Model Unbox(const Object& src)
        {
            return hxcppdbg::core::drivers::dbgeng::native::models::extensions::HxcppdbgModelFactory::instance->GetStoredInstance(src);
        }
    };
}

namespace hxcppdbg::core::drivers::dbgeng::native::models::map
{
    class ModelHash : public Debugger::DataModel::ProviderEx::ExtensionModel
    {
    public:
        ModelHash();

        int count(const Debugger::DataModel::ClientEx::Object&);
        hxcppdbg::core::model::Model at(const Debugger::DataModel::ClientEx::Object&, const int);
    };
}