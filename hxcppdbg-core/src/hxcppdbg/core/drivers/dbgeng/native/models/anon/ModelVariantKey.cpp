#include <hxcpp.h>

#include "models/anon/ModelVariantKey.hpp"
#include "fmt/xchar.h"

hxcppdbg::core::drivers::dbgeng::native::models::anon::ModelVariantKey::ModelVariantKey()
    : hxcppdbg::core::drivers::dbgeng::native::models::extensions::HxcppdbgExtensionModel(std::wstring(L"hx::Anon_obj::VariantKey"))
{
    AddReadOnlyProperty(L"Key", this, &ModelVariantKey::key);
}

Debugger::DataModel::ClientEx::Object hxcppdbg::core::drivers::dbgeng::native::models::anon::ModelVariantKey::key(const Debugger::DataModel::ClientEx::Object& _object)
{
    return _object.FieldValue(L"key");
}

Debugger::DataModel::ClientEx::Object hxcppdbg::core::drivers::dbgeng::native::models::anon::ModelVariantKey::getHxcppdbgModelData(const Debugger::DataModel::ClientEx::Object& _object)
{
    return _object.FieldValue(L"value").KeyValue(L"HxcppdbgModelData");
}