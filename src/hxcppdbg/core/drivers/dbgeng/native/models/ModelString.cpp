#include <hxcpp.h>

#include "models/ModelString.hpp"

hxcppdbg::core::drivers::dbgeng::native::models::ModelString::ModelString()
    : Debugger::DataModel::ProviderEx::ExtensionModel(Debugger::DataModel::ProviderEx::TypeSignatureRegistration(L"String"))
{
    AddReadOnlyProperty(L"Length" , this, &hxcppdbg::core::drivers::dbgeng::native::models::ModelString::getLength);
    AddReadOnlyProperty(L"IsUtf16", this, &hxcppdbg::core::drivers::dbgeng::native::models::ModelString::getIsUtf16);
    AddReadOnlyProperty(L"String" , this, &hxcppdbg::core::drivers::dbgeng::native::models::ModelString::getString);
    AddStringDisplayableFunction(this, &hxcppdbg::core::drivers::dbgeng::native::models::ModelString::getDisplayString);
}

int hxcppdbg::core::drivers::dbgeng::native::models::ModelString::getLength(const Debugger::DataModel::ClientEx::Object& _string)
{
    return _string.FieldValue(L"length").As<int>();
}

bool hxcppdbg::core::drivers::dbgeng::native::models::ModelString::getIsUtf16(const Debugger::DataModel::ClientEx::Object& _string)
{
    return _string.FromBindingExpressionEvaluation(USE_CURRENT_HOST_CONTEXT, _string, L"__w && ((unsigned int *)__w)[-1] & 0x00200000").As<bool>();
}

std::wstring hxcppdbg::core::drivers::dbgeng::native::models::ModelString::getString(const Debugger::DataModel::ClientEx::Object& _string)
{
    auto isUtf16 = getIsUtf16(_string);
    auto length  = getLength(_string);

    return isUtf16
        ? readString<uint16_t>(length, _string.FieldValue(L"__w"))
        : readString<char>(length, _string.FieldValue(L"__s"));
}

std::wstring hxcppdbg::core::drivers::dbgeng::native::models::ModelString::getDisplayString(const Debugger::DataModel::ClientEx::Object& _string, const Debugger::DataModel::ClientEx::Metadata& metadata)
{
    auto isUtf16 = getIsUtf16(_string);
    auto length  = getLength(_string);
    auto value   = getString(_string);
    auto output  = std::wstring();

    output.append(L"( length = ");
    output.append(std::to_wstring(length));
    output.append(L", utf16 = ");
    output.append(std::to_wstring(isUtf16));
    output.append(L" ) ");
    output.append(value);

    return output;
}

template<typename TChar>
std::wstring hxcppdbg::core::drivers::dbgeng::native::models::ModelString::readString(const int length, Debugger::DataModel::ClientEx::Object& cstring)
{
    auto output = std::wstring();

    output.reserve(length);

    for (auto i = 0; i < length; i++)
    {
        output.push_back(cstring.Dereference().As<TChar>());

        cstring++;
    }

    return output;
}