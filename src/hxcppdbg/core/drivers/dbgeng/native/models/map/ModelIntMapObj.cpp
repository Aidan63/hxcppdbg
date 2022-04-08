#include <hxcpp.h>

#include "models/map/ModelIntMapObj.hpp"

hxcppdbg::core::drivers::dbgeng::native::models::map::ModelIntMapObj::ModelIntMapObj()
    : Debugger::DataModel::ProviderEx::ExtensionModel(Debugger::DataModel::ProviderEx::TypeSignatureRegistration(L"haxe::ds::IntMap_obj"))
{
    AddStringDisplayableFunction(this, &hxcppdbg::core::drivers::dbgeng::native::models::map::ModelIntMapObj::getDisplayString);
}

std::wstring hxcppdbg::core::drivers::dbgeng::native::models::map::ModelIntMapObj::getDisplayString(const Debugger::DataModel::ClientEx::Object& object, const Debugger::DataModel::ClientEx::Metadata& metadata)
{
    return object.FieldValue(L"h").TryToDisplayString().value_or(std::wstring(L"unable to read map"));
}