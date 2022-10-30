#pragma once

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

#include "ModelHash.hpp"

namespace hxcppdbg::core::drivers::dbgeng::native::models::map
{
    class ModelIntHash final : public ModelHash
    {
    public:
        ModelIntHash();

        Debugger::DataModel::ClientEx::Object getHxcppdbgModelData(const Debugger::DataModel::ClientEx::Object&);

        bool check(const Debugger::DataModel::ClientEx::Object&, const int, const int) const;
        unsigned int hash(const Debugger::DataModel::ClientEx::Object&, const int) const;
    };
}