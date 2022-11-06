#include <hxcpp.h>

#include "models/anon/ModelVariantKey.hpp"
#include "fmt/xchar.h"

hxcppdbg::core::drivers::dbgeng::native::models::anon::ModelVariantKey::ModelVariantKey()
    : Debugger::DataModel::ProviderEx::ExtensionModel(Debugger::DataModel::ProviderEx::TypeSignatureExtension(L"hx::Anon_obj::VariantKey"))
{
    AddReadOnlyProperty(L"Key", this, &ModelVariantKey::key);
    AddReadOnlyProperty(L"Value", this, &ModelVariantKey::value);
}

Debugger::DataModel::ClientEx::Object hxcppdbg::core::drivers::dbgeng::native::models::anon::ModelVariantKey::key(const Debugger::DataModel::ClientEx::Object& _object)
{
    return _object.FieldValue(L"key").KeyValue(L"String");
}

Debugger::DataModel::ClientEx::Object hxcppdbg::core::drivers::dbgeng::native::models::anon::ModelVariantKey::value(const Debugger::DataModel::ClientEx::Object& _object)
{
    return _object.FieldValue(L"value").KeyValue(L"HxcppdbgModelData");
}