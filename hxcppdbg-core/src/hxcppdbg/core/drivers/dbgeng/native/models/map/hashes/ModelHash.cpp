#include <hxcpp.h>

#include "models/LazyMap.hpp"
#include "models/map/hashes/ModelHash.hpp"
#include "models/extensions/Utils.hpp"
#include "models/extensions/AnonBoxer.hpp"
#include "fmt/xchar.h"

hxcppdbg::core::drivers::dbgeng::native::models::map::hashes::ModelHash::ModelHash(std::wstring _element)
    : hxcppdbg::core::drivers::dbgeng::native::models::extensions::HxcppdbgExtensionModel(fmt::to_wstring(fmt::format(L"hx::Hash<{0}>", _element)))
{
    AddMethod(L"Count", this, &ModelHash::count);
    AddMethod(L"At", this, &ModelHash::at);
    AddMethod(L"Get", this, &ModelHash::get);

    AddReadOnlyProperty(L"KeySize", this, &ModelHash::keySize);
    AddReadOnlyProperty(L"KeyName", this, &ModelHash::keyName);
}

int hxcppdbg::core::drivers::dbgeng::native::models::map::hashes::ModelHash::keySize(const Debugger::DataModel::ClientEx::Object& _object)
{
    return
        _object
            .FieldValue(L"keyCache")
            .FieldValue(L"mPtr")
            .Dereference()
            .GetValue()
            .TryCastToRuntimeType()
            .KeyValue(L"ParamSize")
            .As<int>();
}

std::wstring hxcppdbg::core::drivers::dbgeng::native::models::map::hashes::ModelHash::keyName(const Debugger::DataModel::ClientEx::Object& _object)
{
    return
        _object
            .FieldValue(L"keyCache")
            .FieldValue(L"mPtr")
            .Dereference()
            .GetValue()
            .TryCastToRuntimeType()
            .KeyValue(L"ParamName")
            .As<std::wstring>();
}

Debugger::DataModel::ClientEx::Object hxcppdbg::core::drivers::dbgeng::native::models::map::hashes::ModelHash::count(const Debugger::DataModel::ClientEx::Object& _object)
{
    return _object.FieldValue(L"size");
}

Debugger::DataModel::ClientEx::Object hxcppdbg::core::drivers::dbgeng::native::models::map::hashes::ModelHash::at(const Debugger::DataModel::ClientEx::Object& _object, const int _index, const std::wstring _keyName, const int _keySize)
{
    auto buckets = _object.FieldValue(L"bucket");

    if (buckets.As<uint64_t>() == NULL)
    {
        return hxcppdbg::core::drivers::dbgeng::native::NativeModelData_obj::NNull();
    }

    auto inKey =
        _object
            .FieldValue(L"keyCache")
            .FieldValue(L"mPtr")
            .Dereference()
            .GetValue()
            .TryCastToRuntimeType()
            .CallMethod(L"At", _index, _keyName, _keySize, true);

    auto inHash =
        _object
            .FieldValue(L"hashCache")
            .FieldValue(L"mPtr")
            .Dereference()
            .GetValue()
            .TryCastToRuntimeType()
            .CallMethod(L"At", _index, std::wstring(L"unsigned int"), sizeof(unsigned int), true)
            .As<unsigned int>();

    auto ignore = _object.FieldValue(L"IgnoreHash").As<bool>();
    auto mask   = _object.FieldValue(L"mask").As<int>();
    auto head   = buckets[inHash & mask];

    while (head.As<uint64_t>() != NULL)
    {
        auto element = head.GetValue().Dereference().GetValue();

        if (ignore || element.CallMethod(L"CheckHash", inHash).As<bool>())
        {
            if (element.CallMethod(L"CheckKey", inKey, true).As<bool>())
            {
                auto keyField = element.FieldValue(L"key");
                auto key      = keyField.Type().IsIntrinsic()
                    ? hxcppdbg::core::drivers::dbgeng::native::models::extensions::intrinsicObjectToHxcppdbgModelData(keyField)
                    : keyField.KeyValue(L"HxcppdbgModelData").As<hxcppdbg::core::drivers::dbgeng::native::NativeModelData>();

                auto valueField = element.FieldValue(L"value");
                auto value      = valueField.Type().IsIntrinsic()
                    ? hxcppdbg::core::drivers::dbgeng::native::models::extensions::intrinsicObjectToHxcppdbgModelData(valueField)
                    : valueField.KeyValue(L"HxcppdbgModelData").As<hxcppdbg::core::drivers::dbgeng::native::NativeModelData>();

                auto anon = hx::Anon_obj::Create(2);

                anon->setFixed(0, HX_CSTRING("name"), key);
                anon->setFixed(1, HX_CSTRING("data"), value);

                return hxcppdbg::core::drivers::dbgeng::native::models::extensions::AnonBoxer::Box(anon);
            }
        }

        head = element.FieldValue(L"next");
    }

    return hxcppdbg::core::drivers::dbgeng::native::NativeModelData_obj::NNull();
}

Debugger::DataModel::ClientEx::Object hxcppdbg::core::drivers::dbgeng::native::models::map::hashes::ModelHash::get(const Debugger::DataModel::ClientEx::Object& _object, const Debugger::DataModel::ClientEx::Object _inKey, const Debugger::DataModel::ClientEx::Object _inHash)
{
    auto buckets = _object.FieldValue(L"bucket");

    if (buckets.As<uint64_t>() == NULL)
    {
        return hxcppdbg::core::drivers::dbgeng::native::NativeModelData_obj::NNull();
    }

    auto ignore = _object.FieldValue(L"IgnoreHash").As<bool>();
    auto mask   = _object.FieldValue(L"mask").As<int>();
    auto head   = buckets[_inHash.As<unsigned int>() & mask];

    while (head.As<uint64_t>() != NULL)
    {
        auto element = head.GetValue().Dereference().GetValue();

        if (ignore || element.CallMethod(L"CheckHash", _inHash).As<bool>())
        {
            if (element.CallMethod(L"CheckKey", _inKey, false).As<bool>())
            {
                auto v = element.FieldValue(L"value");

                return hxcppdbg::core::drivers::dbgeng::native::models::extensions::objectToHxcppdbgModelData(v);
            }
        }

        head = element.FieldValue(L"next");
    }

    return hxcppdbg::core::drivers::dbgeng::native::NativeModelData_obj::NNull();
}