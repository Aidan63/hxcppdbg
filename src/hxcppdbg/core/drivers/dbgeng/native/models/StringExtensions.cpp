#include <hxcpp.h>

#include "models/StringExtensions.hpp"

hxcppdbg::core::drivers::dbgeng::native::models::StringExtensions::StringExtensions()
    : Debugger::DataModel::ProviderEx::ExtensionModel(Debugger::DataModel::ProviderEx::TypeSignatureRegistration(L"String"))
{
    AddReadOnlyProperty(L"Length", this, &hxcppdbg::core::drivers::dbgeng::native::models::StringExtensions::Get_Length);
    AddReadOnlyProperty(L"Contents", this, &hxcppdbg::core::drivers::dbgeng::native::models::StringExtensions::Get_Contents);
}

int hxcppdbg::core::drivers::dbgeng::native::models::StringExtensions::Get_Length(const Debugger::DataModel::ClientEx::Object& myStruct)
{
    return static_cast<int>(myStruct.FieldValue(L"length"));
}

std::wstring hxcppdbg::core::drivers::dbgeng::native::models::StringExtensions::Get_Contents(const Debugger::DataModel::ClientEx::Object& myStruct)
{
    auto function  = myStruct.FunctionValue(L"__CStr()");
    auto utf8_cstr = myStruct.Call(function);
    auto wstring   = utf8_cstr.ToDisplayString();

    return wstring;
}