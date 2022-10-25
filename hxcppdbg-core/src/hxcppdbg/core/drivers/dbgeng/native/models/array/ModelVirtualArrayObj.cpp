#include <hxcpp.h>

#include "models/array/ModelVirtualArrayObj.hpp"

enum StoreType
{
    arrayNull = 0,
    arrayEmpty,
    arrayFixed,
    arrayBool,
    arrayInt,
    arrayFloat,
    arrayString,
    arrayObject,
    arrayInt64
};

hxcppdbg::core::drivers::dbgeng::native::models::array::ModelVirtualArrayObj::ModelVirtualArrayObj()
    : hxcppdbg::core::drivers::dbgeng::native::models::extensions::HxcppdbgExtensionModel(std::wstring(L"cpp::VirtualArray_obj"))
{
    //
}

Debugger::DataModel::ClientEx::Object hxcppdbg::core::drivers::dbgeng::native::models::array::ModelVirtualArrayObj::getHxcppdbgModelData(const Debugger::DataModel::ClientEx::Object& object)
{
    if (object.FieldValue(L"store").As<int>() == StoreType::arrayNull)
    {
        return hxcppdbg::core::drivers::dbgeng::native::NativeModelData_obj::NNull();
    }

    return
        object
            .FieldValue(L"base")
            .Dereference()
            .GetValue()
            .TryCastToRuntimeType()
            .KeyValue(L"HxcppdbgModelData");
}