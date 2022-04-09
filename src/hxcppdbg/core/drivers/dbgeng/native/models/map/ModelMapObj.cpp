#include <hxcpp.h>

#include "models/map/ModelMapObj.hpp"
#include "fmt/xchar.h"

hxcppdbg::core::drivers::dbgeng::native::models::map::ModelMapObj::ModelMapObj(std::wstring signature)
    : Debugger::DataModel::ProviderEx::ExtensionModel(Debugger::DataModel::ProviderEx::TypeSignatureRegistration(fmt::to_wstring(fmt::format(L"haxe::ds::{0}Map_obj", signature))))
{
    AddStringDisplayableFunction(this, &hxcppdbg::core::drivers::dbgeng::native::models::map::ModelMapObj::getDisplayString);
}

std::wstring hxcppdbg::core::drivers::dbgeng::native::models::map::ModelMapObj::getDisplayString(const Debugger::DataModel::ClientEx::Object& object, const Debugger::DataModel::ClientEx::Metadata& metadata)
{
    return object.FieldValue(L"h").TryToDisplayString().value_or(std::wstring(L"unable to read map"));
}