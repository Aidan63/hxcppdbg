#include <hxcpp.h>

#include "models/anon/ModelVariantKey.hpp"
#include "fmt/xchar.h"

hxcppdbg::core::drivers::dbgeng::native::models::anon::ModelVariantKey::ModelVariantKey()
    : hxcppdbg::core::drivers::dbgeng::native::models::extensions::HxcppdbgExtensionModel(std::wstring(L"hx::Anon_obj::VariantKey"))
{
    // AddReadOnlyProperty(L"HxcppdbgModel", this, &ModelVariantKey::getHxcppdbgModel);
}

// hxcppdbg::core::model::ModelData hxcppdbg::core::drivers::dbgeng::native::models::anon::ModelVariantKey::getHxcppdbgModelData(const Debugger::DataModel::ClientEx::Object& object)
// {
//     throw std::exception("");
// }

Debugger::DataModel::ClientEx::Object hxcppdbg::core::drivers::dbgeng::native::models::anon::ModelVariantKey::getHxcppdbgModelData(const Debugger::DataModel::ClientEx::Object& object)
{
    return Debugger::DataModel::ClientEx::Object();

    // auto key   = object.FieldValue(L"key").KeyValue(L"String").As<std::wstring>();
    // auto value = object.FieldValue(L"value").KeyValue(L"HxcppdbgModelData").As<hxcppdbg::core::model::ModelData>();

    // return hxcppdbg::core::model::Model_obj::__new(hxcppdbg::core::model::ModelData_obj::MString(String::create(key.c_str(), key.length())), value);
}