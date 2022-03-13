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

        std::wstring getString(const Debugger::DataModel::ClientEx::Object& _string);
        bool getIsUtf16(const Debugger::DataModel::ClientEx::Object& _string);
        int getLength(const Debugger::DataModel::ClientEx::Object& _string);
        std::wstring getDisplayString(const Debugger::DataModel::ClientEx::Object& _string, const Debugger::DataModel::ClientEx::Metadata& _metadata);

    private:
        template<typename TChar>
        static std::wstring readString(const int length, Debugger::DataModel::ClientEx::Object& cstring);
    };
}