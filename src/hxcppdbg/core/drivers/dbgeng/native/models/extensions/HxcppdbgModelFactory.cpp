#include <hxcpp.h>

#include "HxcppdbgModelFactory.hpp"

#ifndef INCLUDED_hxcppdbg_core_model_Model
#include <hxcppdbg/core/model/Model.h>
#endif

hxcppdbg::core::drivers::dbgeng::native::models::extensions::HxcppdbgModelFactory* hxcppdbg::core::drivers::dbgeng::native::models::extensions::HxcppdbgModelFactory::instance = nullptr;

hxcppdbg::core::drivers::dbgeng::native::models::extensions::HxcppdbgModelFactory::HxcppdbgModelFactory()
    : Debugger::DataModel::ProviderEx::TypedInstanceModel<hxcppdbg::core::model::Model>()
{
    //
}