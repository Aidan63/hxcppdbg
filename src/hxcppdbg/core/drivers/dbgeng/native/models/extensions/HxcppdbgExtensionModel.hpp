#pragma once

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

#include "DbgModelClientEx.hpp"
#include "models/extensions/HxcppdbgModelFactory.hpp"
#include "models/extensions/HxcppdbgModelDataFactory.hpp"

HX_DECLARE_CLASS3(hxcppdbg, core, model, Model)
HX_DECLARE_CLASS3(hxcppdbg, core, model, ModelData)

namespace hxcppdbg::core::drivers::dbgeng::native::models::extensions
{
    class HxcppdbgExtensionModel : public Debugger::DataModel::ProviderEx::ExtensionModel
    {
    public:
        HxcppdbgExtensionModel(std::wstring signature);

        virtual hxcppdbg::core::model::ModelData getHxcppdbgModelData(const Debugger::DataModel::ClientEx::Object& object) = 0;
    };
}

namespace Debugger::DataModel::ClientEx::Boxing
{
    template<>
    struct BoxObject<hxcppdbg::core::model::ModelData>
    {
        static Object Box(const hxcppdbg::core::model::ModelData& model)
        {
            return hxcppdbg::core::drivers::dbgeng::native::models::extensions::HxcppdbgModelDataFactory::instance->CreateInstance(model);
        }

        static hxcppdbg::core::model::ModelData Unbox(const Object& src)
        {
            return hxcppdbg::core::drivers::dbgeng::native::models::extensions::HxcppdbgModelDataFactory::instance->GetStoredInstance(src);
        }
    };
}

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
