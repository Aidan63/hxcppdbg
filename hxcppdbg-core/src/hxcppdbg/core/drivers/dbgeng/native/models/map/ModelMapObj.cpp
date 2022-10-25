#include <hxcpp.h>

#include "models/map/ModelMapObj.hpp"
#include "fmt/xchar.h"

hxcppdbg::core::drivers::dbgeng::native::models::map::ModelMapObj::ModelMapObj(std::wstring signature)
    : hxcppdbg::core::drivers::dbgeng::native::models::extensions::HxcppdbgExtensionModel(fmt::to_wstring(fmt::format(L"haxe::ds::{0}Map_obj", signature)))
{
    //
}

Debugger::DataModel::ClientEx::Object hxcppdbg::core::drivers::dbgeng::native::models::map::ModelMapObj::getHxcppdbgModelData(const Debugger::DataModel::ClientEx::Object& object)
{
    return
        object
            .FieldValue(L"h")
            .KeyValue(L"HxcppdbgModelData");
}