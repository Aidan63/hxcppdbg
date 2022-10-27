#pragma once

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

#include "models/extensions/HxcppdbgExtensionModel.hpp"

namespace hxcppdbg::core::drivers::dbgeng::native::models::map
{
    class ModelHash : public hxcppdbg::core::drivers::dbgeng::native::models::extensions::HxcppdbgExtensionModel
    {
    public:
        ModelHash();

        Debugger::DataModel::ClientEx::Object getHxcppdbgModelData(const Debugger::DataModel::ClientEx::Object&);

        int count(const Debugger::DataModel::ClientEx::Object&);
        hxcppdbg::core::drivers::dbgeng::native::NativeModelData key(const Debugger::DataModel::ClientEx::Object&, const int);
        hxcppdbg::core::drivers::dbgeng::native::NativeModelData value(const Debugger::DataModel::ClientEx::Object&, const int);
    };
}