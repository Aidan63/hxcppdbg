#include <hxcpp.h>

#include "models/anon/ModelVariantKey.hpp"
#include "fmt/xchar.h"

#ifndef INCLUDED_hxcppdbg_core_model_ModelData
#include <hxcppdbg/core/model/ModelData.h>
#endif

#ifndef INCLUDED_hxcppdbg_core_model_Model
#include <hxcppdbg/core/model/Model.h>
#endif

hxcppdbg::core::drivers::dbgeng::native::models::anon::ModelVariantKey::ModelVariantKey()
    : hxcppdbg::core::drivers::dbgeng::native::models::extensions::HxcppdbgExtensionModel(std::wstring(L"hx::Anon_obj::VariantKey"))
{
    AddReadOnlyProperty(L"HxcppdbgModel", this, &ModelVariantKey::getHxcppdbgModel);
}

hxcppdbg::core::model::ModelData hxcppdbg::core::drivers::dbgeng::native::models::anon::ModelVariantKey::getHxcppdbgModelData(const Debugger::DataModel::ClientEx::Object& object)
{
    throw std::exception("");
}

hxcppdbg::core::model::Model hxcppdbg::core::drivers::dbgeng::native::models::anon::ModelVariantKey::getHxcppdbgModel(const Debugger::DataModel::ClientEx::Object& object)
{
    auto key   = object.FieldValue(L"key").KeyValue(L"String").As<std::wstring>();
    auto value = object.FieldValue(L"value").KeyValue(L"HxcppdbgModelData").As<hxcppdbg::core::model::ModelData>();

    return hxcppdbg::core::model::Model_obj::__new(hxcppdbg::core::model::ModelData_obj::MString(String::create(key.c_str(), key.length())), value);
}