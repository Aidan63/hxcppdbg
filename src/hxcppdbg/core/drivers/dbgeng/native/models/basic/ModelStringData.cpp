#include <hxcpp.h>

#include "models/basic/ModelStringData.hpp"

#ifndef INCLUDED_hxcppdbg_core_model_ModelData
#include <hxcppdbg/core/model/ModelData.h>
#endif

#ifndef INCLUDED_hxcppdbg_core_model_Model
#include <hxcppdbg/core/model/Model.h>
#endif

hxcppdbg::core::drivers::dbgeng::native::models::basic::ModelStringData::ModelStringData()
    : hxcppdbg::core::drivers::dbgeng::native::models::extensions::HxcppdbgExtensionModel(std::wstring(L"hx::StringData"))
{
    //
}

hxcppdbg::core::model::ModelData hxcppdbg::core::drivers::dbgeng::native::models::basic::ModelStringData::getHxcppdbgModelData(const Debugger::DataModel::ClientEx::Object& object)
{
    return object.FieldValue(L"mValue").KeyValue(L"HxcppdbgModelData").As<hxcppdbg::core::model::ModelData>();
}