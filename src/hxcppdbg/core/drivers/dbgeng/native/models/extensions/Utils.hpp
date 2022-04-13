#pragma once

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

#include "DbgModelClientEx.hpp"

HX_DECLARE_CLASS3(hxcppdbg, core, model, ModelData)

namespace hxcppdbg::core::drivers::dbgeng::native::models::extensions
{
    hxcppdbg::core::model::ModelData intrinsicObjectToHxcppdbgModelData(const Debugger::DataModel::ClientEx::Object object);
}