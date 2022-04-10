#include <hxcpp.h>

#include "models/anon/ModelAnonObj.hpp"

hxcppdbg::core::drivers::dbgeng::native::models::anon::ModelAnonObj::ModelAnonObj()
    : Debugger::DataModel::ProviderEx::ExtensionModel(Debugger::DataModel::ProviderEx::TypeSignatureRegistration(L"hx::Anon_obj"))
{
    AddStringDisplayableFunction(this, &hxcppdbg::core::drivers::dbgeng::native::models::anon::ModelAnonObj::getDisplayString);
}

std::wstring hxcppdbg::core::drivers::dbgeng::native::models::anon::ModelAnonObj::getDisplayString(const Debugger::DataModel::ClientEx::Object& object, const Debugger::DataModel::ClientEx::Metadata& metadata)
{
    auto pointer     = object.FromBindingExpressionEvaluation(USE_CURRENT_HOST_CONTEXT, object, L"(hx::Anon_obj::VariantKey *)(self + 1)");
    auto fixedFields = object.FieldValue(L"mFixedFields").As<int>();
    auto output      = object.FieldValue(L"mFields").ToDisplayString();

    for (auto i = 0; i < fixedFields; i++)
    {
        auto fixed = pointer.Dereference().GetValue().ToDisplayString();

        output.append(L" ");
        output.append(fixed);

        pointer++;
    }

    return output;
}