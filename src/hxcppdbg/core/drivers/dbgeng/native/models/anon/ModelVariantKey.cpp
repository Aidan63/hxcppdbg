#include <hxcpp.h>

#include "models/anon/ModelVariantKey.hpp"
#include "fmt/xchar.h"

hxcppdbg::core::drivers::dbgeng::native::models::anon::ModelVariantKey::ModelVariantKey()
    : Debugger::DataModel::ProviderEx::ExtensionModel(Debugger::DataModel::ProviderEx::TypeSignatureRegistration(L"hx::Anon_obj::VariantKey"))
{
    AddStringDisplayableFunction(this, &hxcppdbg::core::drivers::dbgeng::native::models::anon::ModelVariantKey::getDisplayString);
}

std::wstring hxcppdbg::core::drivers::dbgeng::native::models::anon::ModelVariantKey::getDisplayString(const Debugger::DataModel::ClientEx::Object& object, const Debugger::DataModel::ClientEx::Metadata& metadata)
{
    auto key    = object.FieldValue(L"key").KeyValue(L"String").As<std::wstring>();
    auto value  = object.FieldValue(L"value").ToDisplayString();
    auto output = fmt::to_wstring(fmt::format(L"( {0} : {1} )", key, value));

    return output;
}