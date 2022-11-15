#include <hxcpp.h>

#include "HxcppdbgExtensionModel.hpp"

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