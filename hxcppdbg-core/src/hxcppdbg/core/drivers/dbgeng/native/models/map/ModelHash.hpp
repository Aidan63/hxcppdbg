#pragma once

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

#include "NativeModelData.hpp"

namespace hxcppdbg::core::drivers::dbgeng::native::models::map
{
    class ModelHash : public Debugger::DataModel::ProviderEx::ExtensionModel
    {
    public:
        ModelHash();

        int count(const Debugger::DataModel::ClientEx::Object&);
        hxcppdbg::core::drivers::dbgeng::native::NativeModelData at(const Debugger::DataModel::ClientEx::Object&, const int);
    };
}