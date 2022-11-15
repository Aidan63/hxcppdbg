#include <hxcpp.h>

#include "models/ModelObjectPtr.hpp"

hxcppdbg::core::drivers::dbgeng::native::models::ModelObjectPtr::ModelObjectPtr(std::wstring signature)
    : extensions::HxcppdbgExtensionModel(signature)
{
    //
}

Debugger::DataModel::ClientEx::Object hxcppdbg::core::drivers::dbgeng::native::models::ModelObjectPtr::getHxcppdbgModelData(const Debugger::DataModel::ClientEx::Object& _object)
{
    return
        _object
            .FieldValue(L"mPtr")
            .Dereference()
            .GetValue()
            .TryCastToRuntimeType()
            .KeyValue(L"HxcppdbgModelData");
}

Debugger::DataModel::ClientEx::Object hxcppdbg::core::drivers::dbgeng::native::models::ModelObjectPtr::getHash(const Debugger::DataModel::ClientEx::Object& _object)
{
    auto ptr = _object.FieldValue(L"mPtr");
    if (ptr.As<ULONG64>() == NULL)
    {
        return 0;
    }
    else
    {
        return
            ptr
                .Dereference()
                .GetValue()
                .FieldValue(L"__hx_cachedHash");
    }
}