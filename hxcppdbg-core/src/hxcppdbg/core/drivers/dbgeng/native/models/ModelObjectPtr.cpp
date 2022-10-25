#include <hxcpp.h>

#include "models/ModelObjectPtr.hpp"

hxcppdbg::core::drivers::dbgeng::native::models::ModelObjectPtr::ModelObjectPtr(std::wstring signature)
    : extensions::HxcppdbgExtensionModel(signature)
{
    //
}

Debugger::DataModel::ClientEx::Object hxcppdbg::core::drivers::dbgeng::native::models::ModelObjectPtr::getHxcppdbgModelData(const Debugger::DataModel::ClientEx::Object& object)
{
    return
        object
            .FieldValue(L"mPtr")
            .Dereference()
            .GetValue()
            .TryCastToRuntimeType()
            .KeyValue(L"HxcppdbgModelData");
}