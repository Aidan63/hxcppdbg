#pragma once

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

#include "models/extensions/HxcppdbgExtensionModel.hpp"

namespace hxcppdbg::core::drivers::dbgeng::native::models::basic
{
    class ModelString : public hxcppdbg::core::drivers::dbgeng::native::models::extensions::HxcppdbgExtensionModel
    {
    public:
        ModelString();

        std::wstring getString(const Debugger::DataModel::ClientEx::Object& _string);
        bool getIsUtf16(const Debugger::DataModel::ClientEx::Object& _string);
        int getLength(const Debugger::DataModel::ClientEx::Object& _string);

        Debugger::DataModel::ClientEx::Object getHxcppdbgModelData(const Debugger::DataModel::ClientEx::Object& object);

    private:
        template<typename TChar>
        static std::wstring readString(const int length, Debugger::DataModel::ClientEx::Object& cstring);
    };
}