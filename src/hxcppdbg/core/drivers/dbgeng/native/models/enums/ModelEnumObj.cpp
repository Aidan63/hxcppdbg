#include <hxcpp.h>

#include "models/enums/ModelEnumObj.hpp"

#include "fmt/xchar.h"

hxcppdbg::core::drivers::dbgeng::native::models::enums::ModelEnumObj::ModelEnumObj(std::wstring signature)
    : Debugger::DataModel::ProviderEx::ExtensionModel(Debugger::DataModel::ProviderEx::TypeSignatureRegistration(signature))
{
    AddStringDisplayableFunction(this, &hxcppdbg::core::drivers::dbgeng::native::models::enums::ModelEnumObj::getDisplayString);
}

std::wstring hxcppdbg::core::drivers::dbgeng::native::models::enums::ModelEnumObj::getDisplayString(const Debugger::DataModel::ClientEx::Object& object, const Debugger::DataModel::ClientEx::Metadata& metadata)
{
    auto tag        = object.FieldValue(L"_hx_tag").KeyValue(L"String").As<std::wstring>();
    auto fieldCount = object.FieldValue(L"mFixedFields").As<int>();

    if (fieldCount == 0)
    {
        return tag;
    }

    tag.push_back(L'(');

    auto variants = object.FromBindingExpressionEvaluation(USE_CURRENT_HOST_CONTEXT, object, L"(cpp::Variant *)(self + 1)");
    for (auto i = 0; i < fieldCount; i++)
    {
        auto variant = variants.Dereference().GetValue();
        auto display = variant.ToDisplayString();

        tag.append(display);
        tag.append(i < fieldCount - 1 ? L", " : L"");

        variants++;
    }

    tag.push_back(L')');

    return tag;
}