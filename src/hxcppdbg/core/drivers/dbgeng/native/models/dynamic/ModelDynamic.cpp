#include <hxcpp.h>

#include "models/dynamic/ModelDynamic.hpp"

hxcppdbg::core::drivers::dbgeng::native::models::dynamic::ModelDynamic::ModelDynamic()
    : Debugger::DataModel::ProviderEx::ExtensionModel(Debugger::DataModel::ProviderEx::TypeSignatureRegistration(L"Dynamic"))
{
    AddStringDisplayableFunction(this, &hxcppdbg::core::drivers::dbgeng::native::models::dynamic::ModelDynamic::getDisplayString);
}

std::wstring hxcppdbg::core::drivers::dbgeng::native::models::dynamic::ModelDynamic::getDisplayString(const Debugger::DataModel::ClientEx::Object& object, const Debugger::DataModel::ClientEx::Metadata& metadata)
{
    auto ptr = object.FieldValue(L"mPtr");
    if (ptr.As<ULONG64>() == NULL)
    {
        return std::wstring(L"null");
    }
    else
    {
        auto value = ptr.Dereference().GetValue().TryCastToRuntimeType();
        auto type  = value.Type();
        auto name  = type.Name();
        auto disp  = value.TryToDisplayString().value_or(std::wstring(L"unable to print object"));

        return disp;
    }
}