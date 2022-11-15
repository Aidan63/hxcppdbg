#pragma once

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

#include "models/extensions/HxcppdbgExtensionModel.hpp"

namespace hxcppdbg::core::drivers::dbgeng::native::models::map::hashes
{
    class ModelHash : public hxcppdbg::core::drivers::dbgeng::native::models::extensions::HxcppdbgExtensionModel
    {
    public:
        ModelHash(std::wstring);

        Debugger::DataModel::ClientEx::Object count(const Debugger::DataModel::ClientEx::Object&);
        Debugger::DataModel::ClientEx::Object at(const Debugger::DataModel::ClientEx::Object&, const int, const std::wstring, const int);
        Debugger::DataModel::ClientEx::Object get(const Debugger::DataModel::ClientEx::Object&, const Debugger::DataModel::ClientEx::Object, const Debugger::DataModel::ClientEx::Object);

        int keySize(const Debugger::DataModel::ClientEx::Object&);
        std::wstring keyName(const Debugger::DataModel::ClientEx::Object&);
    };
}