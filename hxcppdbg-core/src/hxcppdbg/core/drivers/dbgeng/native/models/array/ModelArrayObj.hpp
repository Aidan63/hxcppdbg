#pragma once

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

#include "models/extensions/HxcppdbgExtensionModel.hpp"

namespace hxcppdbg::core::drivers::dbgeng::native::models::array
{
    class ModelArrayObj : public hxcppdbg::core::drivers::dbgeng::native::models::extensions::HxcppdbgExtensionModel
    {
    public:
        ModelArrayObj();

        Debugger::DataModel::ClientEx::Object getHxcppdbgModelData(const Debugger::DataModel::ClientEx::Object&);
        
        hxcppdbg::core::drivers::dbgeng::native::NativeModelData at(const Debugger::DataModel::ClientEx::Object&, const int);
        int count(const Debugger::DataModel::ClientEx::Object&);
    };
}