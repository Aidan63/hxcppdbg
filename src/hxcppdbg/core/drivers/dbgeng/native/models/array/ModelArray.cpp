#include <hxcpp.h>

#include "models/array/ModelArray.hpp"

hxcppdbg::core::drivers::dbgeng::native::models::array::ModelArray::ModelArray()
    : Debugger::DataModel::ProviderEx::ExtensionModel(Debugger::DataModel::ProviderEx::TypeSignatureRegistration(L"Array<*>"))
{
    AddStringDisplayableFunction(this, &hxcppdbg::core::drivers::dbgeng::native::models::array::ModelArray::getDisplayString);
}

std::wstring hxcppdbg::core::drivers::dbgeng::native::models::array::ModelArray::getDisplayString(const Debugger::DataModel::ClientEx::Object& _array, const Debugger::DataModel::ClientEx::Metadata& _metadata)
{
    auto mptr = _array.FieldValue(L"mPtr");
    auto obj  = mptr.Dereference().GetValue().TryCastToRuntimeType();
    auto str  = obj.TryToDisplayString().value_or(std::wstring(L"unable to display object"));

    return str;
}