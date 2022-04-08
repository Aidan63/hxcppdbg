#include <hxcpp.h>
#include "models/dynamic/ModelReferenceDynamic.hpp"

hxcppdbg::core::drivers::dbgeng::native::models::dynamic::ModelReferenceDynamic::ModelReferenceDynamic(const wchar_t * typeSignature)
    : Debugger::DataModel::ProviderEx::ExtensionModel(Debugger::DataModel::ProviderEx::TypeSignatureRegistration(typeSignature))
{
    AddStringDisplayableFunction(this, &hxcppdbg::core::drivers::dbgeng::native::models::dynamic::ModelReferenceDynamic::getDisplayString);
}

std::wstring hxcppdbg::core::drivers::dbgeng::native::models::dynamic::ModelReferenceDynamic::getDisplayString(const Debugger::DataModel::ClientEx::Object& object, const Debugger::DataModel::ClientEx::Metadata& metadata)
{
    return object.FieldValue(L"mValue").TryToDisplayString().value_or(std::wstring(L"unable to print object"));
}