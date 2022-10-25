#pragma once

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

#include "models/extensions/HxcppdbgExtensionModel.hpp"

namespace hxcppdbg::core::drivers::dbgeng::native::models::array
{
    class ModelVirtualArrayObj : public hxcppdbg::core::drivers::dbgeng::native::models::extensions::HxcppdbgExtensionModel
    {
    public:
        ModelVirtualArrayObj();

        Debugger::DataModel::ClientEx::Object getHxcppdbgModelData(const Debugger::DataModel::ClientEx::Object& object);
    };
}