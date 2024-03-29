#pragma once

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

#include "DbgModelClientEx.hpp"
#include "NativeModelData.hpp"

namespace hxcppdbg::core::drivers::dbgeng::native::models::extensions
{
    NativeModelData objectToHxcppdbgModelData(const Debugger::DataModel::ClientEx::Object& object);
    NativeModelData intrinsicObjectToHxcppdbgModelData(const Debugger::DataModel::ClientEx::Object& object);
}