#include <hxcpp.h>

#include "models/map/ModelHashElement.hpp"

hxcppdbg::core::drivers::dbgeng::native::models::map::ModelHashElement::ModelHashElement(std::wstring signature)
    : Debugger::DataModel::ProviderEx::ExtensionModel(Debugger::DataModel::ProviderEx::TypeSignatureRegistration(signature))
{
    AddStringDisplayableFunction(this, &hxcppdbg::core::drivers::dbgeng::native::models::map::ModelHashElement::getDisplayString);
}

std::wstring hxcppdbg::core::drivers::dbgeng::native::models::map::ModelHashElement::getDisplayString(const Debugger::DataModel::ClientEx::Object& object, const Debugger::DataModel::ClientEx::Metadata& metadata)
{
    auto key     = object.FieldValue(L"key").TryToDisplayString().value_or(std::wstring(L"unable to read key"));
    auto value   = object.FieldValue(L"value").TryToDisplayString().value_or(std::wstring(L"unable to read key"));
    auto nextPtr = object.FieldValue(L"next");

    auto output = std::wstring();
    output.append(L"{ ");
    output.append(key);
    output.append(L" => ");
    output.append(value);
    output.append(L" }");

    if (nextPtr.As<ULONG64>() != NULL)
    {
        output.append(L", ");

        auto next    = nextPtr.Dereference().GetValue();
        auto display = next.TryToDisplayString().value_or(std::wstring(L"{ unable to read element }"));
        
        output.append(display);
    }

    return output;
}