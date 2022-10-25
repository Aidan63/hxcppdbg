#include <hxcpp.h>

#include "models/dynamic/ModelDynamic.hpp"

hxcppdbg::core::drivers::dbgeng::native::models::dynamic::ModelDynamic::ModelDynamic()
    : hxcppdbg::core::drivers::dbgeng::native::models::extensions::HxcppdbgExtensionModel(std::wstring(L"Dynamic"))
{
    //
}

Debugger::DataModel::ClientEx::Object hxcppdbg::core::drivers::dbgeng::native::models::dynamic::ModelDynamic::getHxcppdbgModelData(const Debugger::DataModel::ClientEx::Object& object)
{
    auto ptr = object.FieldValue(L"mPtr");
    if (ptr.As<ULONG64>() == NULL)
    {
        return hxcppdbg::core::drivers::dbgeng::native::NativeModelData_obj::NNull();
    }
    else
    {
        return
            ptr
                .Dereference()
                .GetValue()
                .TryCastToRuntimeType()
                .KeyValue(L"HxcppdbgModelData");
    }
}