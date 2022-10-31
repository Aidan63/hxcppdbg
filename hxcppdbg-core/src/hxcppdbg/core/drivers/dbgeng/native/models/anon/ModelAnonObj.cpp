#include <hxcpp.h>

#include "models/anon/ModelAnonObj.hpp"
#include "models/LazyAnonFields.hpp"
#include "NativeModelData.hpp"

hxcppdbg::core::drivers::dbgeng::native::models::anon::ModelAnonObj::ModelAnonObj()
    : hxcppdbg::core::drivers::dbgeng::native::models::extensions::HxcppdbgExtensionModel(std::wstring(L"hx::Anon_obj"))
{
    AddMethod(L"Count", this, &ModelAnonObj::count);
    AddMethod(L"Field", this, &ModelAnonObj::field);
}

Debugger::DataModel::ClientEx::Object hxcppdbg::core::drivers::dbgeng::native::models::anon::ModelAnonObj::getHxcppdbgModelData(const Debugger::DataModel::ClientEx::Object& _object)
{
    return NativeModelData_obj::HxAnon(new LazyAnonFields(_object));
}

Debugger::DataModel::ClientEx::Object hxcppdbg::core::drivers::dbgeng::native::models::anon::ModelAnonObj::count(const Debugger::DataModel::ClientEx::Object& _object)
{
    auto fixedCount = _object.FieldValue(L"mFixedFields").As<int>();
    auto dynFields  = _object.FieldValue(L"mFields").FieldValue(L"mPtr");

    if (dynFields.As<uint64_t>() != NULL)
    {
        auto hash =
            dynFields
                .Dereference()
                .GetValue()
                .TryCastToRuntimeType();

        return fixedCount + hash.CallMethod(L"Count").As<int>();
    }
    else
    {
        return fixedCount;
    }
}

Debugger::DataModel::ClientEx::Object hxcppdbg::core::drivers::dbgeng::native::models::anon::ModelAnonObj::field(const Debugger::DataModel::ClientEx::Object& _object, const std::wstring _field)
{
    auto variants   = _object.FromBindingExpressionEvaluation(USE_CURRENT_HOST_CONTEXT, _object, L"(hx::Anon_obj::VariantKey *)(self + 1)");
    auto fixedCount = _object.FieldValue(L"mFixedFields").As<int>();

    for (auto i = 0; i < fixedCount; i++)
    {
        if (variants[i].GetValue().KeyValue(L"Key").KeyValue(L"String").As<std::wstring>() == _field)
        {
            return variants[i].GetValue().KeyValue(L"HxcppdbgModelData");
        }
    }

    auto dynFields = _object.FieldValue(L"mFields").FieldValue(L"mPtr");

    if (dynFields.As<uint64_t>() != NULL)
    {
        return
            dynFields
                .Dereference()
                .GetValue()
                .TryCastToRuntimeType()
                .CallMethod(L"Value", _field);
    }
    else
    {
        return NativeModelData_obj::NNull();
    }
}