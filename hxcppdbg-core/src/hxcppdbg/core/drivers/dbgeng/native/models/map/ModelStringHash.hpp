#pragma once

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

#include "ModelHash.hpp"

namespace hxcppdbg::core::drivers::dbgeng::native::models::map
{
    class ModelStringHash final : public ModelHash
    {
    public:
        ModelStringHash();

        Debugger::DataModel::ClientEx::Object getHxcppdbgModelData(const Debugger::DataModel::ClientEx::Object&);

        bool check(const Debugger::DataModel::ClientEx::Object&, const Debugger::DataModel::ClientEx::Object, const std::wstring) const;
        unsigned int hash(const Debugger::DataModel::ClientEx::Object&, const std::wstring) const;
    };
}