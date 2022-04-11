#pragma once

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

#include "models/extensions/HxcppdbgExtensionModel.hpp"

namespace hxcppdbg::core::drivers::dbgeng::native::models
{
    class ModelString : public extensions::HxcppdbgExtensionModel
    {
    public:
        ModelString();

        std::wstring getString(const Debugger::DataModel::ClientEx::Object& _string);
        bool getIsUtf16(const Debugger::DataModel::ClientEx::Object& _string);
        int getLength(const Debugger::DataModel::ClientEx::Object& _string);

        hxcppdbg::core::model::ModelData getHxcppdbgModelData(const Debugger::DataModel::ClientEx::Object& object);

    private:
        template<typename TChar>
        static std::wstring readString(const int length, Debugger::DataModel::ClientEx::Object& cstring);
    };
}