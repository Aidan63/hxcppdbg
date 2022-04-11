#include <hxcpp.h>

#include "HxcppdbgModelDataFactory.hpp"

#ifndef INCLUDED_hxcppdbg_core_model_ModelData
#include <hxcppdbg/core/model/ModelData.h>
#endif

hxcppdbg::core::drivers::dbgeng::native::models::extensions::HxcppdbgModelDataFactory* hxcppdbg::core::drivers::dbgeng::native::models::extensions::HxcppdbgModelDataFactory::instance = nullptr;

hxcppdbg::core::drivers::dbgeng::native::models::extensions::HxcppdbgModelDataFactory::HxcppdbgModelDataFactory()
    : Debugger::DataModel::ProviderEx::TypedInstanceModel<hxcppdbg::core::model::ModelData>()
{
    //
}