#include <hxcpp.h>

#include "models/array/ModelVirtualArrayObj.hpp"

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
    : Debugger::DataModel::ProviderEx::ExtensionModel(Debugger::DataModel::ProviderEx::TypeSignatureRegistration(L"cpp::VirtualArray_obj"))
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