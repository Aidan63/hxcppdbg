#include <hxcpp.h>

#include "models/map/elements/ModelElement.hpp"

hxcppdbg::core::drivers::dbgeng::native::models::map::elements::ModelElement::ModelElement(std::wstring _element)
    : Debugger::DataModel::ProviderEx::ExtensionModel(Debugger::DataModel::ProviderEx::TypeSignatureExtension(_element))
{
    AddMethod(L"CheckHash", this, &ModelElement::checkHash);
    AddMethod(L"CheckKey", this, &ModelElement::checkKey);
}