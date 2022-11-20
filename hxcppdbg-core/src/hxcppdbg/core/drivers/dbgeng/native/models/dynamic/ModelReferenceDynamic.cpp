#include <hxcpp.h>

#include "models/dynamic/ModelReferenceDynamic.hpp"
#include "models/extensions/Utils.hpp"

hxcppdbg::core::drivers::dbgeng::native::models::dynamic::ModelReferenceDynamic::ModelReferenceDynamic(std::wstring signature)
    : hxcppdbg::core::drivers::dbgeng::native::models::extensions::HxcppdbgExtensionModel(signature)
{
    //
}

Debugger::DataModel::ClientEx::Object hxcppdbg::core::drivers::dbgeng::native::models::dynamic::ModelReferenceDynamic::getHxcppdbgModelData(const Debugger::DataModel::ClientEx::Object& object)
{
    auto value = object.FieldValue(L"mValue");
    auto type  = value.Type();

    if (type.IsIntrinsic())
    {
        return hxcppdbg::core::drivers::dbgeng::native::models::extensions::intrinsicObjectToHxcppdbgModelData(value);
    }
    else
    {
        return value.KeyValue(L"HxcppdbgModelData");
    }
}