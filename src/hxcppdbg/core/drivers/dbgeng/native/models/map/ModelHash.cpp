#include <hxcpp.h>

#include "models/map/ModelHash.hpp"
#include "fmt/xchar.h"

#ifndef INCLUDED_hxcppdbg_core_model_ModelData
#include <hxcppdbg/core/model/ModelData.h>
#endif

#ifndef INCLUDED_hxcppdbg_core_model_Model
#include <hxcppdbg/core/model/Model.h>
#endif

hxcppdbg::core::drivers::dbgeng::native::models::map::ModelHash::ModelHash()
    : hxcppdbg::core::drivers::dbgeng::native::models::extensions::HxcppdbgExtensionModel(L"hx::Hash<*>")
{
    AddStringDisplayableFunction(this, &ModelHash::getDisplayString);
    AddGeneratorFunction(this, &ModelHash::getIterator);
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
        if (hashPtr.As<ULONG64>() == NULL)
        {
            continue;
        }

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

hxcppdbg::core::model::ModelData hxcppdbg::core::drivers::dbgeng::native::models::map::ModelHash::getHxcppdbgModelData(const Debugger::DataModel::ClientEx::Object& object)
{
    auto output = Array<hxcppdbg::core::model::Model>(0, 0);

    for (auto&& element : object)
    {
        auto m = element.As<hxcppdbg::core::model::Model>();

        output->Add(m);
    }
    
    return hxcppdbg::core::model::ModelData_obj::MMap(output);
}

std::experimental::generator<hxcppdbg::core::model::Model> hxcppdbg::core::drivers::dbgeng::native::models::map::ModelHash::getIterator(const Debugger::DataModel::ClientEx::Object& object)
{
    auto bucketCount = object.FieldValue(L"bucketCount").As<int>();
    auto buckets     = object.FieldValue(L"bucket");

    for (auto i = 0; i < bucketCount; i++)
    {
        // If the current hash pointer is null, skip, not sure if we can exit early or not.
        auto pointer = buckets.Dereference().GetValue();
        if (pointer.As<ULONG64>() == NULL)
        {
            continue;
        }

        auto bucket = pointer.Dereference().GetValue();
        for (auto&& element : bucket)
        {
            co_yield(element.As<hxcppdbg::core::model::Model>());
        }

        buckets++;
    }
}