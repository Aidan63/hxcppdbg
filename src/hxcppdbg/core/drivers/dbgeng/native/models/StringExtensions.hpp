#pragma once

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

#include "DbgModelClientEx.hpp"

namespace hxcppdbg::core::drivers::dbgeng::native::models
{
    class StringExtensions : public Debugger::DataModel::ProviderEx::ExtensionModel
    {
    public:
        StringExtensions();

        std::wstring Get_Contents(const Debugger::DataModel::ClientEx::Object& myStruct);
        int Get_Length(const Debugger::DataModel::ClientEx::Object& myStruct);
    };
}