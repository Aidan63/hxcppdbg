#pragma once

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

#include "models/extensions/HxcppdbgExtensionModel.hpp"

namespace hxcppdbg::core::drivers::dbgeng::native::models::map::elements
{
    class ModelElement : public Debugger::DataModel::ProviderEx::ExtensionModel
    {
    public:
        ModelElement(std::wstring);

        virtual bool checkHash(const Debugger::DataModel::ClientEx::Object&, const Debugger::DataModel::ClientEx::Object) = 0;
        virtual bool checkKey(const Debugger::DataModel::ClientEx::Object&, const Debugger::DataModel::ClientEx::Object, const bool) = 0;
    };
}