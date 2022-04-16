#include <hxcpp.h>

#include "models/dynamic/ModelReferenceDynamic.hpp"
#include "models/extensions/Utils.hpp"

#ifndef INCLUDED_hxcppdbg_core_model_ModelData
#include <hxcppdbg/core/model/ModelData.h>
#endif

#ifndef INCLUDED_hxcppdbg_core_model_Model
#include <hxcppdbg/core/model/Model.h>
#endif

hxcppdbg::core::drivers::dbgeng::native::models::dynamic::ModelReferenceDynamic::ModelReferenceDynamic(std::wstring signature)
    : hxcppdbg::core::drivers::dbgeng::native::models::extensions::HxcppdbgExtensionModel(signature)
{
    //
}

hxcppdbg::core::model::ModelData hxcppdbg::core::drivers::dbgeng::native::models::dynamic::ModelReferenceDynamic::getHxcppdbgModelData(const Debugger::DataModel::ClientEx::Object& object)
{
    auto value = object.FieldValue(L"mValue");
    auto type  = value.Type();

    if (type.IsIntrinsic())
    {
        return hxcppdbg::core::drivers::dbgeng::native::models::extensions::intrinsicObjectToHxcppdbgModelData(value);
    }
    else
    {
        return
            value
                .KeyValue(L"HxcppdbgModelData")
                .As<hxcppdbg::core::model::ModelData>();
    }
}