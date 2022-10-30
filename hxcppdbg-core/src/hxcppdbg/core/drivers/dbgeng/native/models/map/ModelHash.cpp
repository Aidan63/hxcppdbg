#include <hxcpp.h>

#include "models/map/ModelHash.hpp"
#include "models/LazyMap.hpp"
#include "models/extensions/Utils.hpp"
#include "fmt/xchar.h"

hxcppdbg::core::drivers::dbgeng::native::models::map::ModelHash::ModelHash(std::wstring _element)
    : hxcppdbg::core::drivers::dbgeng::native::models::extensions::HxcppdbgExtensionModel(fmt::to_wstring(fmt::format(L"hx::Hash<{0}>", _element)))
{
    AddMethod(L"Count", this, &ModelHash::count);
    AddMethod(L"Key", this, &ModelHash::key);
    AddMethod(L"Value", this, &ModelHash::value);
}

Debugger::DataModel::ClientEx::Object hxcppdbg::core::drivers::dbgeng::native::models::map::ModelHash::count(const Debugger::DataModel::ClientEx::Object& _object)
{
    return _object.FieldValue(L"size");
}

Debugger::DataModel::ClientEx::Object hxcppdbg::core::drivers::dbgeng::native::models::map::ModelHash::key(const Debugger::DataModel::ClientEx::Object& _object, const int _index)
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

Debugger::DataModel::ClientEx::Object hxcppdbg::core::drivers::dbgeng::native::models::map::ModelHash::value(const Debugger::DataModel::ClientEx::Object& _object, const Debugger::DataModel::ClientEx::Object _inKey)
{
    auto buckets = _object.FieldValue(L"bucket");

    if (buckets.As<uint64_t>() == NULL)
    {
        return hxcppdbg::core::drivers::dbgeng::native::NativeModelData_obj::NNull();
    }

    auto inHash = this->GetObject().CallMethod(L"Hash", _inKey).As<unsigned int>();
    auto ignore = _object.FieldValue(L"IgnoreHash").As<bool>();
    auto mask   = _object.FieldValue(L"mask").As<int>();
    auto head   = buckets[inHash & mask];

    while (head.As<uint64_t>() != NULL)
    {
        auto value = head.GetValue().Dereference().GetValue();

        if (ignore || value.FieldValue(L"hash").As<unsigned int>() == inHash)
        {
            if (this->GetObject().CallMethod(L"Check", value.FieldValue(L"key"), _inKey).As<bool>())
            {
                auto v = value.FieldValue(L"value");

                return
                    v.Type().IsIntrinsic()
                        ? hxcppdbg::core::drivers::dbgeng::native::models::extensions::intrinsicObjectToHxcppdbgModelData(v)
                        : v.KeyValue(L"HxcppdbgModelData");
            }
        }

        head = value.FieldValue(L"next");
    }

    return hxcppdbg::core::drivers::dbgeng::native::NativeModelData_obj::NNull();
}