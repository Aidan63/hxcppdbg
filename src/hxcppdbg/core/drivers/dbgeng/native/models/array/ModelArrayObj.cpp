#include <hxcpp.h>

#include "models/array/ModelArrayObj.hpp"
#include "fmt/xchar.h"

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
    auto elementSize = object.FromExpressionEvaluation(USE_CURRENT_HOST_CONTEXT, fmt::to_wstring(fmt::format(L"sizeof({0})", paramName))).As<int>();
    auto output      = fmt::to_wstring(fmt::format(L"( length = {0}, allocated = {1} ) [ ", length, allocated));

    for (auto i = 0; i < length; i++)
    {
        auto expr    = fmt::to_wstring(fmt::format(L"({0}*)(mBase + {1})", paramName, i * elementSize));
        auto element = object.FromBindingExpressionEvaluation(USE_CURRENT_HOST_CONTEXT, object, expr).Dereference().GetValue();
        auto display = element.TryToDisplayString().value_or(L"( unable to read element )");

        output.append(display);
        output.append(i < length - 1 ? L", " : L" ");
    }

    output.append(L"]");

    return output;
}