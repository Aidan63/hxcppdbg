#include <hxcpp.h>

#include "models/array/ModelVirtualArrayObj.hpp"

#ifndef INCLUDED_hxcppdbg_core_model_ModelData
#include <hxcppdbg/core/model/ModelData.h>
#endif

#ifndef INCLUDED_hxcppdbg_core_model_Model
#include <hxcppdbg/core/model/Model.h>
#endif

enum StoreType {
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
    : hxcppdbg::core::drivers::dbgeng::native::models::extensions::HxcppdbgExtensionModel(L"cpp::VirtualArray_obj")
{
    AddStringDisplayableFunction(this, &hxcppdbg::core::drivers::dbgeng::native::models::array::ModelVirtualArrayObj::getDisplayString);
}

std::wstring hxcppdbg::core::drivers::dbgeng::native::models::array::ModelVirtualArrayObj::getDisplayString(const Debugger::DataModel::ClientEx::Object& object, const Debugger::DataModel::ClientEx::Metadata& metadata)
{
    auto storeType = object.FieldValue(L"store").As<int>();

    if (storeType == StoreType::arrayEmpty)
    {
        return std::wstring(L"( length = 0 allocated = 0 ) []");
    }
    if (storeType == StoreType::arrayNull)
    {
        return std::wstring(L"null");
    }

    auto arrayBase = object.FieldValue(L"base").Dereference().GetValue().TryCastToRuntimeType();

    return arrayBase.TryToDisplayString().value_or(std::wstring(L"Unable to display array"));
}

hxcppdbg::core::model::ModelData hxcppdbg::core::drivers::dbgeng::native::models::array::ModelVirtualArrayObj::getHxcppdbgModelData(const Debugger::DataModel::ClientEx::Object& object)
{
    auto storeType = object.FieldValue(L"store").As<int>();

    if (storeType == StoreType::arrayNull)
    {
        return hxcppdbg::core::model::ModelData_obj::MNull;
    }

    auto arrayBase = object.FieldValue(L"base").Dereference().GetValue().TryCastToRuntimeType();

    return arrayBase.KeyValue(L"HxcppdbgModelData").As<hxcppdbg::core::model::ModelData>();
}