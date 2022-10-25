#pragma once

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

#include "models/extensions/HxcppdbgExtensionModel.hpp"

HX_DECLARE_CLASS3(hxcppdbg, core, sourcemap, GeneratedType)

namespace hxcppdbg::core::drivers::dbgeng::native::models::enums
{
    class ModelEnumObj : public hxcppdbg::core::drivers::dbgeng::native::models::extensions::HxcppdbgExtensionModel
    {
    private:
        hxcppdbg::core::sourcemap::GeneratedType type;
        
    public:
        ModelEnumObj(hxcppdbg::core::sourcemap::GeneratedType);

        Debugger::DataModel::ClientEx::Object getHxcppdbgModelData(const Debugger::DataModel::ClientEx::Object& object);
    };
}