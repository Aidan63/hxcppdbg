#include <hxcpp.h>

#include "models/map/ModelMapObj.hpp"
#include "fmt/xchar.h"

#ifndef INCLUDED_hxcppdbg_core_model_ModelData
#include <hxcppdbg/core/model/ModelData.h>
#endif

#ifndef INCLUDED_hxcppdbg_core_model_Model
#include <hxcppdbg/core/model/Model.h>
#endif

hxcppdbg::core::drivers::dbgeng::native::models::map::ModelMapObj::ModelMapObj(std::wstring signature)
    : hxcppdbg::core::drivers::dbgeng::native::models::extensions::HxcppdbgExtensionModel(fmt::to_wstring(fmt::format(L"haxe::ds::{0}Map_obj", signature)))
{
    //
}

hxcppdbg::core::model::ModelData hxcppdbg::core::drivers::dbgeng::native::models::map::ModelMapObj::getHxcppdbgModelData(const Debugger::DataModel::ClientEx::Object& object)
{
    return object.FieldValue(L"h").KeyValue(L"HxcppdbgModelData").As<hxcppdbg::core::model::ModelData>();
}