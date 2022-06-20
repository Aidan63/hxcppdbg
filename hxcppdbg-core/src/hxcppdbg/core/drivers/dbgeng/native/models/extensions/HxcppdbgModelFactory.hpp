#pragma once

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

#include "DbgModelClientEx.hpp"

HX_DECLARE_CLASS3(hxcppdbg, core, model, Model)

namespace hxcppdbg::core::drivers::dbgeng::native::models::extensions
{
    class HxcppdbgModelFactory : public Debugger::DataModel::ProviderEx::TypedInstanceModel<hxcppdbg::core::model::Model>
    {
    public:
        HxcppdbgModelFactory();

        static HxcppdbgModelFactory* instance;
    };
}
