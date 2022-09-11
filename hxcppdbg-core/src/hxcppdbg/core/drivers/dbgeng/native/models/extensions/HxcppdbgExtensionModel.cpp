#include <hxcpp.h>

#include "HxcppdbgExtensionModel.hpp"

#ifndef INCLUDED_hxcppdbg_core_model_Model
#include <hxcppdbg/core/model/Model.h>
#endif

#ifndef INCLUDED_hxcppdbg_core_model_ModelData
#include <hxcppdbg/core/model/ModelData.h>
#endif

hxcppdbg::core::drivers::dbgeng::native::models::extensions::HxcppdbgExtensionModel::HxcppdbgExtensionModel(std::wstring signature)
    : Debugger::DataModel::ProviderEx::ExtensionModel::ExtensionModel(Debugger::DataModel::ProviderEx::TypeSignatureExtension(signature))
{
    AddReadOnlyProperty(L"HxcppdbgModelData", this, &HxcppdbgExtensionModel::getHxcppdbgModelData);
}

hxcppdbg::core::drivers::dbgeng::native::models::extensions::HxcppdbgExtensionModel::HxcppdbgExtensionModel(const char16_t* signature)
    : Debugger::DataModel::ProviderEx::ExtensionModel::ExtensionModel(Debugger::DataModel::ProviderEx::TypeSignatureExtension(reinterpret_cast<const wchar_t*>(signature)))
{
    AddReadOnlyProperty(L"HxcppdbgModelData", this, &HxcppdbgExtensionModel::getHxcppdbgModelData);
}
