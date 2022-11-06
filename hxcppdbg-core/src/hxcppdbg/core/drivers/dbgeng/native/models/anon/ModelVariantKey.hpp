#pragma once

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

#include "DbgModelClientEx.hpp"

namespace hxcppdbg::core::drivers::dbgeng::native::models::anon
{
    class ModelVariantKey : public Debugger::DataModel::ProviderEx::ExtensionModel
    {
    public:
        ModelVariantKey();

        Debugger::DataModel::ClientEx::Object key(const Debugger::DataModel::ClientEx::Object&);
        Debugger::DataModel::ClientEx::Object value(const Debugger::DataModel::ClientEx::Object&);
    };
}