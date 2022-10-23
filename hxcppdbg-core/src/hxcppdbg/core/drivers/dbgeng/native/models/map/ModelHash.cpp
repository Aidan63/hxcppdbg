#include <hxcpp.h>

#include "models/map/ModelHash.hpp"
#include "fmt/xchar.h"

#ifndef INCLUDED_hxcppdbg_core_model_ModelData
#include <hxcppdbg/core/model/ModelData.h>
#endif

#ifndef INCLUDED_hxcppdbg_core_model_Model
#include <hxcppdbg/core/model/Model.h>
#endif

using namespace Debugger::DataModel::ClientEx;
using namespace Debugger::DataModel::ProviderEx;

hxcppdbg::core::drivers::dbgeng::native::models::map::ModelHash::ModelHash()
    : ExtensionModel(TypeSignatureExtension(std::wstring(L"hx::Hash<*>")))
{
    AddMethod(L"Count", this, &ModelHash::count);
    AddMethod(L"At", this, &ModelHash::at);
}

int hxcppdbg::core::drivers::dbgeng::native::models::map::ModelHash::count(const Object& _object)
{
    return _object.FieldValue(L"size").As<int>();
}

hxcppdbg::core::model::Model hxcppdbg::core::drivers::dbgeng::native::models::map::ModelHash::at(const Object& _object, const int _index)
{
    auto bucketCount = _object.FieldValue(L"bucketCount").As<int>();
    auto buckets     = _object.FieldValue(L"bucket");
    auto accumulated = 0;

    for (auto i = 0; i < bucketCount; i++)
    {
        // If the current hash pointer is null, skip, not sure if we can exit early or not.
        auto pointer = buckets.Dereference().GetValue();
        if (pointer.As<uint64_t>() == NULL)
        {
            buckets++;

            continue;
        }

        auto element      = pointer.Dereference().GetValue();
        auto elementCount = element.CallMethod(L"Count").As<int>();
        if (_index >= accumulated && _index < accumulated + elementCount)
        {
            return element.CallMethod(L"At", _index - accumulated).As<hxcppdbg::core::model::Model>();
        }

        accumulated += elementCount;
    }
}
