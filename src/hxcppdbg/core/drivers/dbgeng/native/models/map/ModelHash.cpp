#include <hxcpp.h>

#include "models/map/ModelHash.hpp"
#include "fmt/xchar.h"

hxcppdbg::core::drivers::dbgeng::native::models::map::ModelHash::ModelHash()
    : Debugger::DataModel::ProviderEx::ExtensionModel(Debugger::DataModel::ProviderEx::TypeSignatureRegistration(L"hx::Hash<*>"))
{
    AddStringDisplayableFunction(this, &hxcppdbg::core::drivers::dbgeng::native::models::map::ModelHash::getDisplayString);
}

std::wstring hxcppdbg::core::drivers::dbgeng::native::models::map::ModelHash::getDisplayString(const Debugger::DataModel::ClientEx::Object& object, const Debugger::DataModel::ClientEx::Metadata& metadata)
{
    auto size        = object.FieldValue(L"size").As<int>();
    auto bucketCount = object.FieldValue(L"bucketCount").As<int>();
    auto buckets     = object.FieldValue(L"bucket");
    auto output      = fmt::to_wstring(fmt::format(L"( size = {0} ) [ ", size));

    for (auto i = 0; i < bucketCount; i++)
    {
        auto hashPtr = buckets.Dereference().GetValue();
        auto hash    = hashPtr.Dereference().GetValue();
        auto type    = hash.TryCastToRuntimeType();
        auto display = type.TryToDisplayString().value_or(std::wstring(L"{ unable to read element }"));

        output.append(display);
        output.append(i < bucketCount - 1 ? L", " : L" ");

        buckets++;
    }

    output.append(L"]");

    return output;
}