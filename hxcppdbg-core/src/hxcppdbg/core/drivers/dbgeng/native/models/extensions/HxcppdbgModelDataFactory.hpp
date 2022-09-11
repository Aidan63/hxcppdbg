#pragma once

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

#include "DbgModelClientEx.hpp"

HX_DECLARE_CLASS3(hxcppdbg, core, model, ModelData)

namespace hxcppdbg::core::drivers::dbgeng::native::models::extensions
{
    class HxcppdbgModelDataFactory : public Debugger::DataModel::ProviderEx::TypedInstanceModel<hxcppdbg::core::model::ModelData>
    {
    public:
        HxcppdbgModelDataFactory();

        static HxcppdbgModelDataFactory* instance;
    };
}
