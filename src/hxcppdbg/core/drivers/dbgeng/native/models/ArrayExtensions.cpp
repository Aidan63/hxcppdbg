#include <hxcpp.h>

#include "models/ArrayExtensions.hpp"

hxcppdbg::core::drivers::dbgeng::native::models::ArrayExtensions::ArrayExtensions()
    : Debugger::DataModel::ProviderEx::ExtensionModel(Debugger::DataModel::ProviderEx::TypeSignatureRegistration(L"Array<*>"))
{
    AddStringDisplayableFunction(this, &hxcppdbg::core::drivers::dbgeng::native::models::ArrayExtensions::getDisplayString);
}

std::wstring hxcppdbg::core::drivers::dbgeng::native::models::ArrayExtensions::getDisplayString(const Debugger::DataModel::ClientEx::Object& _array, const Debugger::DataModel::ClientEx::Metadata& _metadata)
{
    auto mptr = _array.FieldValue(L"mPtr");
    auto obj  = mptr.Dereference().GetValue();
    auto str  = obj.ToDisplayString();

    return str;
}