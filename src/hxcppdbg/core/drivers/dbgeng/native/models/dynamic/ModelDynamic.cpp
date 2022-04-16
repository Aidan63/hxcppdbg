#include <hxcpp.h>

#include "models/dynamic/ModelDynamic.hpp"

#ifndef INCLUDED_hxcppdbg_core_model_ModelData
#include <hxcppdbg/core/model/ModelData.h>
#endif

#ifndef INCLUDED_hxcppdbg_core_model_Model
#include <hxcppdbg/core/model/Model.h>
#endif

hxcppdbg::core::drivers::dbgeng::native::models::dynamic::ModelDynamic::ModelDynamic()
    : hxcppdbg::core::drivers::dbgeng::native::models::extensions::HxcppdbgExtensionModel(L"Dynamic")
{
    //
}

hxcppdbg::core::model::ModelData hxcppdbg::core::drivers::dbgeng::native::models::dynamic::ModelDynamic::getHxcppdbgModelData(const Debugger::DataModel::ClientEx::Object& object)
{
    auto ptr = object.FieldValue(L"mPtr");
    if (ptr.As<ULONG64>() == NULL)
    {
        return hxcppdbg::core::model::ModelData_obj::MNull;
    }
    else
    {
        return
            ptr
                .Dereference()
                .GetValue()
                .TryCastToRuntimeType()
                .KeyValue(L"HxcppdbgModelData")
                .As<hxcppdbg::core::model::ModelData>();
    }
}