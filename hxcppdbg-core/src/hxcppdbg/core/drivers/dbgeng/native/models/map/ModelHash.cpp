#include <hxcpp.h>

#include "models/map/ModelHash.hpp"
#include "models/LazyMap.hpp"
#include "models/extensions/Utils.hpp"
#include "fmt/xchar.h"
#include "../extensions/AnonBoxer.hpp"

hxcppdbg::core::drivers::dbgeng::native::models::map::ModelHash::ModelHash(std::wstring _element)
    : hxcppdbg::core::drivers::dbgeng::native::models::extensions::HxcppdbgExtensionModel(fmt::to_wstring(fmt::format(L"hx::Hash<{0}>", _element)))
{
    AddMethod(L"Count", this, &ModelHash::count);
    AddMethod(L"At", this, &ModelHash::at);
    AddMethod(L"Get", this, &ModelHash::get);
}

Debugger::DataModel::ClientEx::Object hxcppdbg::core::drivers::dbgeng::native::models::map::ModelHash::count(const Debugger::DataModel::ClientEx::Object& _object)
{
    return _object.FieldValue(L"size");
}

Debugger::DataModel::ClientEx::Object hxcppdbg::core::drivers::dbgeng::native::models::map::ModelHash::at(const Debugger::DataModel::ClientEx::Object& _object, const int _index)
{
    auto bucketCount = _object.FieldValue(L"bucketCount").As<int>();
    auto buckets     = _object.FieldValue(L"bucket");
    auto count       = 0;

    for (auto i = 0; i < bucketCount; i++)
    {
        // If the current hash pointer is null, skip, not sure if we can exit early or not.
        auto pointer = buckets.Dereference().GetValue();
        if (pointer.As<uint64_t>() == NULL)
        {
            buckets++;

            continue;
        }

        auto current = pointer.Dereference().GetValue();

        while (true)
        {
            if (count == _index)
            {
                auto nameObj = current.FieldValue(L"key");
                auto name    = nameObj.Type().IsIntrinsic()
                    ? hxcppdbg::core::drivers::dbgeng::native::models::extensions::intrinsicObjectToHxcppdbgModelData(nameObj)
                    : nameObj.KeyValue(L"HxcppdbgModelData").As<hxcppdbg::core::drivers::dbgeng::native::NativeModelData>();

                auto dataObj = current.FieldValue(L"value");
                auto data    = dataObj.Type().IsIntrinsic()
                    ? hxcppdbg::core::drivers::dbgeng::native::models::extensions::intrinsicObjectToHxcppdbgModelData(dataObj)
                    : dataObj.KeyValue(L"HxcppdbgModelData").As<hxcppdbg::core::drivers::dbgeng::native::NativeModelData>();

                auto anon = hx::Anon_obj::Create(2);

                anon->setFixed(0, HX_CSTRING("name"), name);
                anon->setFixed(1, HX_CSTRING("data"), data);

                return hxcppdbg::core::drivers::dbgeng::native::models::extensions::AnonBoxer::Box(anon);
            }

            count++;

            auto next = current.FieldValue(L"next");
            if (next.As<ULONG64>() == NULL)
            {
                break;
            }

            current = next.Dereference().GetValue();
        }
    }

    return hxcppdbg::core::drivers::dbgeng::native::NativeModelData_obj::NNull();
}

Debugger::DataModel::ClientEx::Object hxcppdbg::core::drivers::dbgeng::native::models::map::ModelHash::get(const Debugger::DataModel::ClientEx::Object& _object, const Debugger::DataModel::ClientEx::Object _inKey)
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