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
        ModelHash(std::wstring);

        Debugger::DataModel::ClientEx::Object count(const Debugger::DataModel::ClientEx::Object&);
        Debugger::DataModel::ClientEx::Object key(const Debugger::DataModel::ClientEx::Object&, const int);
        Debugger::DataModel::ClientEx::Object value(const Debugger::DataModel::ClientEx::Object&, const Debugger::DataModel::ClientEx::Object);
    };
}