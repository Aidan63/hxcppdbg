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

        hxcppdbg::core::model::ModelData getHxcppdbgModelData(const Debugger::DataModel::ClientEx::Object&);
        hxcppdbg::core::model::ModelData at(const Debugger::DataModel::ClientEx::Object&, const int, const int);
        int length(const Debugger::DataModel::ClientEx::Object&);
        int elementSize(const Debugger::DataModel::ClientEx::Object&);
    };
}