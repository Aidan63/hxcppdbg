#pragma once

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

#include "models/extensions/HxcppdbgExtensionModel.hpp"

HX_DECLARE_CLASS3(hxcppdbg, core, sourcemap, GeneratedType)

namespace hxcppdbg::core::drivers::dbgeng::native::models::classes
{
    class ModelClassObj : public hxcppdbg::core::drivers::dbgeng::native::models::extensions::HxcppdbgExtensionModel
    {
    private:
        hxcppdbg::core::sourcemap::GeneratedType type;

    public:
        ModelClassObj(hxcppdbg::core::sourcemap::GeneratedType);

        Debugger::DataModel::ClientEx::Object getHxcppdbgModelData(const Debugger::DataModel::ClientEx::Object&);
        Debugger::DataModel::ClientEx::Object count(const Debugger::DataModel::ClientEx::Object&);
        Debugger::DataModel::ClientEx::Object at(const Debugger::DataModel::ClientEx::Object&, const int);
        Debugger::DataModel::ClientEx::Object get(const Debugger::DataModel::ClientEx::Object&, const std::wstring);
    };
}