#pragma once

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

#include "models/extensions/HxcppdbgExtensionModel.hpp"

namespace hxcppdbg::core::drivers::dbgeng::native::models::anon
{
    class ModelAnonObj : public hxcppdbg::core::drivers::dbgeng::native::models::extensions::HxcppdbgExtensionModel
    {
    public:
        ModelAnonObj();

        Debugger::DataModel::ClientEx::Object getHxcppdbgModelData(const Debugger::DataModel::ClientEx::Object& object);
        Debugger::DataModel::ClientEx::Object count(const Debugger::DataModel::ClientEx::Object&);
        Debugger::DataModel::ClientEx::Object field(const Debugger::DataModel::ClientEx::Object&, const std::wstring);
    };
}