#include <hxcpp.h>

#include "models/LazyMap.hpp"
#include "models/map/ModelHash.hpp"
#include "fmt/xchar.h"

using namespace Debugger::DataModel::ClientEx;
using namespace Debugger::DataModel::ProviderEx;

hxcppdbg::core::drivers::dbgeng::native::models::map::ModelHash::ModelHash()
    : hxcppdbg::core::drivers::dbgeng::native::models::extensions::HxcppdbgExtensionModel(std::wstring(L"hx::Hash<*>"))
{
    AddMethod(L"Count", this, &ModelHash::count);
    AddMethod(L"Key", this, &ModelHash::key);
    AddMethod(L"Value", this, &ModelHash::value);
}

Debugger::DataModel::ClientEx::Object hxcppdbg::core::drivers::dbgeng::native::models::map::ModelHash::getHxcppdbgModelData(const Debugger::DataModel::ClientEx::Object& _object)
{
    return
        hxcppdbg::core::drivers::dbgeng::native::NativeModelData_obj::HxMap(
            new hxcppdbg::core::drivers::dbgeng::native::models::LazyMap(_object));
}

int hxcppdbg::core::drivers::dbgeng::native::models::map::ModelHash::count(const Object& _object)
{
    return _object.FieldValue(L"size").As<int>();
}

hxcppdbg::core::drivers::dbgeng::native::NativeModelData hxcppdbg::core::drivers::dbgeng::native::models::map::ModelHash::key(const Object& _object, const int _index)
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
            return element.CallMethod(L"Key", _index - accumulated).As<hxcppdbg::core::drivers::dbgeng::native::NativeModelData>();
        }

        accumulated += elementCount;
    }

    return hxcppdbg::core::drivers::dbgeng::native::NativeModelData_obj::NNull();
}

hxcppdbg::core::drivers::dbgeng::native::NativeModelData hxcppdbg::core::drivers::dbgeng::native::models::map::ModelHash::value(const Object& _object, const int _index)
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
            return element.CallMethod(L"Value", _index - accumulated).As<hxcppdbg::core::drivers::dbgeng::native::NativeModelData>();
        }

        accumulated += elementCount;
    }

    return hxcppdbg::core::drivers::dbgeng::native::NativeModelData_obj::NNull();
}