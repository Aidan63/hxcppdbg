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
        
        Debugger::DataModel::ClientEx::Object at(const Debugger::DataModel::ClientEx::Object&, const int, const std::wstring, const int, const std::optional<bool>);
        int count(const Debugger::DataModel::ClientEx::Object&);

    private:
        static int getParamSize(const Debugger::DataModel::ClientEx::Object&);
        static std::wstring getParamName(const Debugger::DataModel::ClientEx::Object&);
    };
}