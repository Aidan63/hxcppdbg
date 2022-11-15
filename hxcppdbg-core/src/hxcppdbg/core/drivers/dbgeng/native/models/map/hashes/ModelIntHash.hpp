#pragma once

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

#include "models/map/hashes/ModelHash.hpp"

namespace hxcppdbg::core::drivers::dbgeng::native::models::map::hashes
{
    class ModelIntHash : public hxcppdbg::core::drivers::dbgeng::native::models::map::hashes::ModelHash
    {
    public:
        ModelIntHash();

        Debugger::DataModel::ClientEx::Object getHxcppdbgModelData(const Debugger::DataModel::ClientEx::Object&);
    };
}