#include <hxcpp.h>

#include "HxcppdbgExtensionModel.hpp"

#ifndef INCLUDED_hxcppdbg_core_model_ModelData
#include <hxcppdbg/core/model/ModelData.h>
#endif

hxcppdbg::core::drivers::dbgeng::native::models::extensions::HxcppdbgExtensionModel::HxcppdbgExtensionModel(std::wstring signature)
    : Debugger::DataModel::ProviderEx::ExtensionModel::ExtensionModel(Debugger::DataModel::ProviderEx::TypeSignatureRegistration(signature))
{
    AddReadOnlyProperty(L"HxcppdbgModelData", this, &HxcppdbgExtensionModel::getHxcppdbgModelData);
}
