#include <hxcpp.h>

#include "models/basic/ModelString.hpp"

#ifndef INCLUDED_hxcppdbg_core_model_ModelData
#include <hxcppdbg/core/model/ModelData.h>
#endif

hxcppdbg::core::drivers::dbgeng::native::models::basic::ModelString::ModelString()
    : hxcppdbg::core::drivers::dbgeng::native::models::extensions::HxcppdbgExtensionModel(std::wstring(L"String"))
{
    AddReadOnlyProperty(L"Length" , this, &hxcppdbg::core::drivers::dbgeng::native::models::basic::ModelString::getLength);
    AddReadOnlyProperty(L"IsUtf16", this, &hxcppdbg::core::drivers::dbgeng::native::models::basic::ModelString::getIsUtf16);
    AddReadOnlyProperty(L"String" , this, &hxcppdbg::core::drivers::dbgeng::native::models::basic::ModelString::getString);
}

int hxcppdbg::core::drivers::dbgeng::native::models::basic::ModelString::getLength(const Debugger::DataModel::ClientEx::Object& _string)
{
    return _string.FieldValue(L"length").As<int>();
}

bool hxcppdbg::core::drivers::dbgeng::native::models::basic::ModelString::getIsUtf16(const Debugger::DataModel::ClientEx::Object& _string)
{
    return _string.FromBindingExpressionEvaluation(USE_CURRENT_HOST_CONTEXT, _string, L"__w && ((unsigned int *)__w)[-1] & 0x00200000").As<bool>();
}

std::wstring hxcppdbg::core::drivers::dbgeng::native::models::basic::ModelString::getString(const Debugger::DataModel::ClientEx::Object& _string)
{
    auto isUtf16 = getIsUtf16(_string);
    auto length  = getLength(_string);

    return isUtf16
        ? readString<uint16_t>(length, _string.FieldValue(L"__w"))
        : readString<char>(length, _string.FieldValue(L"__s"));
}

hxcppdbg::core::model::ModelData hxcppdbg::core::drivers::dbgeng::native::models::basic::ModelString::getHxcppdbgModelData(const Debugger::DataModel::ClientEx::Object& object)
{
    auto str   = getString(object);
    auto hxStr = String::create(str.c_str());

    return hxcppdbg::core::model::ModelData_obj::MString(hxStr);
}

template<typename TChar>
std::wstring hxcppdbg::core::drivers::dbgeng::native::models::basic::ModelString::readString(const int length, Debugger::DataModel::ClientEx::Object& cstring)
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