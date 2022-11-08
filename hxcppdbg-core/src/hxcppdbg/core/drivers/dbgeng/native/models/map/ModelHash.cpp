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

    AddReadOnlyProperty(L"KeySize", this, &ModelHash::keySize);
    AddReadOnlyProperty(L"KeyName", this, &ModelHash::keyName);
}

int hxcppdbg::core::drivers::dbgeng::native::models::map::ModelHash::keySize(const Debugger::DataModel::ClientEx::Object& _object)
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

std::wstring hxcppdbg::core::drivers::dbgeng::native::models::map::ModelHash::keyName(const Debugger::DataModel::ClientEx::Object& _object)
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

Debugger::DataModel::ClientEx::Object hxcppdbg::core::drivers::dbgeng::native::models::map::ModelHash::count(const Debugger::DataModel::ClientEx::Object& _object)
{
    return _object.FieldValue(L"size");
}

Debugger::DataModel::ClientEx::Object hxcppdbg::core::drivers::dbgeng::native::models::map::ModelHash::at(const Debugger::DataModel::ClientEx::Object& _object, const int _index, const std::wstring _keyName, const int _keySize)
{
    auto bucketCount = _object.FieldValue(L"bucketCount").As<int>();
    auto cachedKeys  = _object.FieldValue(L"keyCache");

    auto key =
        cachedKeys
            .FieldValue(L"mPtr")
            .Dereference()
            .GetValue()
            .TryCastToRuntimeType()
            .CallMethod(L"At", _index, _keyName, _keySize)
            .As<hxcppdbg::core::drivers::dbgeng::native::NativeModelData>();
    
    auto value = hxcppdbg::core::drivers::dbgeng::native::NativeModelData();

    switch (static_cast<hxcppdbg::core::drivers::dbgeng::native::NativeModelData_obj::Type>(key->_hx_getIndex()))
    {
        case hxcppdbg::core::drivers::dbgeng::native::NativeModelData_obj::Type::TInt:
            value = _object.CallMethod(L"Get", key->_hx_getInt(0)).As<hxcppdbg::core::drivers::dbgeng::native::NativeModelData>();
            break;

        case hxcppdbg::core::drivers::dbgeng::native::NativeModelData_obj::Type::THxString:
            value = _object.CallMethod(L"Get", std::wstring(key->_hx_getString(0).wchar_str())).As<hxcppdbg::core::drivers::dbgeng::native::NativeModelData>();
            break;

        default:
            throw std::runtime_error("Unsupported key type");
    }

    auto anon = hx::Anon_obj::Create(2);

    anon->setFixed(0, HX_CSTRING("name"), key);
    anon->setFixed(1, HX_CSTRING("data"), value);

    return hxcppdbg::core::drivers::dbgeng::native::models::extensions::AnonBoxer::Box(anon);
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