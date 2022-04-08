#include <hxcpp.h>

#include "models/ModelObjectPtr.hpp"

hxcppdbg::core::drivers::dbgeng::native::models::ModelObjectPtr::ModelObjectPtr(std::wstring signature)
    : Debugger::DataModel::ProviderEx::ExtensionModel(Debugger::DataModel::ProviderEx::TypeSignatureRegistration(signature))
{
    AddStringDisplayableFunction(this, &hxcppdbg::core::drivers::dbgeng::native::models::ModelObjectPtr::getDisplayString);
}

std::wstring hxcppdbg::core::drivers::dbgeng::native::models::ModelObjectPtr::getDisplayString(const Debugger::DataModel::ClientEx::Object& _array, const Debugger::DataModel::ClientEx::Metadata& _metadata)
{
    auto mptr = _array.FieldValue(L"mPtr");
    auto obj  = mptr.Dereference().GetValue().TryCastToRuntimeType();
    auto str  = obj.TryToDisplayString().value_or(std::wstring(L"unable to display object"));

    return str;
}