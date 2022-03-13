#include <hxcpp.h>

#include "models/ArrayObjExtensions.hpp"

hxcppdbg::core::drivers::dbgeng::native::models::ArrayObjExtensions::ArrayObjExtensions()
    : Debugger::DataModel::ProviderEx::ExtensionModel(Debugger::DataModel::ProviderEx::TypeSignatureRegistration(L"Array_obj<int>"))
{
    AddStringDisplayableFunction(this, &hxcppdbg::core::drivers::dbgeng::native::models::ArrayObjExtensions::getDisplayString);
}

std::wstring hxcppdbg::core::drivers::dbgeng::native::models::ArrayObjExtensions::getDisplayString(const Debugger::DataModel::ClientEx::Object& _array, const Debugger::DataModel::ClientEx::Metadata& _metadata)
{
    auto length    = _array.FieldValue(L"length").As<int>();
    auto allocated = _array.FieldValue(L"mAlloc").As<int>();
    auto basePtr   = _array.FieldValue(L"mBase");
    auto output    = std::wstring();

    output.append(L"( length = ");
    output.append(std::to_wstring(length));
    output.append(L" allocated = ");
    output.append(std::to_wstring(allocated));
    output.append(L" ) [ ");

    for (auto i = 0; i < length; i++)
    {
        auto value = basePtr.Dereference().As<int>();

        output.append(std::to_wstring(value));
        output.append(L" ");

        basePtr += sizeof(int);
    }

    output.append(L"]");

    return output;
}