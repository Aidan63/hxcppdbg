#include <hxcpp.h>

#include "models/array/ModelArrayObj.hpp"

hxcppdbg::core::drivers::dbgeng::native::models::array::ModelArrayObj::ModelArrayObj()
    : Debugger::DataModel::ProviderEx::ExtensionModel(Debugger::DataModel::ProviderEx::TypeSignatureRegistration(L"Array_obj<*>"))
{
    AddStringDisplayableFunction(this, &hxcppdbg::core::drivers::dbgeng::native::models::array::ModelArrayObj::getDisplayString);
}

std::wstring hxcppdbg::core::drivers::dbgeng::native::models::array::ModelArrayObj::getDisplayString(const Debugger::DataModel::ClientEx::Object& object, const Debugger::DataModel::ClientEx::Metadata& metadata)
{
    auto length      = object.FieldValue(L"length").As<int>();
    auto allocated   = object.FieldValue(L"mAlloc").As<int>();
    auto paramName   = object.Type().GenericArguments()[0].Name();
    auto expression  = std::wstring(L"sizeof(") + paramName + std::wstring(L")");
    auto elementSize = object.FromExpressionEvaluation(USE_CURRENT_HOST_CONTEXT, expression).As<int>();
    auto output      = std::wstring();

    output.append(L"( length = ");
    output.append(std::to_wstring(length));
    output.append(L" allocated = ");
    output.append(std::to_wstring(allocated));
    output.append(L" ) [ ");

    for (auto i = 0; i < length; i++)
    {
        auto expr    = std::wstring(L"((") + paramName + std::wstring(L"*)(mBase + ") + std::wstring(std::to_wstring(i * elementSize)) + std::wstring(L"))");
        auto element = object.FromBindingExpressionEvaluation(USE_CURRENT_HOST_CONTEXT, object, expr).Dereference().GetValue();
        auto display = element.TryToDisplayString().value_or(L"(item)");

        output.append(display);
        output.append(i < length - 1 ? L", " : L" ");
    }

    output.append(L"]");

    return output;
}