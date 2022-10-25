#include <hxcpp.h>

#include "models/basic/ModelStringData.hpp"

hxcppdbg::core::drivers::dbgeng::native::models::basic::ModelStringData::ModelStringData()
    : hxcppdbg::core::drivers::dbgeng::native::models::extensions::HxcppdbgExtensionModel(std::wstring(L"hx::StringData"))
{
    //
}

Debugger::DataModel::ClientEx::Object hxcppdbg::core::drivers::dbgeng::native::models::basic::ModelStringData::getHxcppdbgModelData(const Debugger::DataModel::ClientEx::Object& object)
{
    return
        object
            .FieldValue(L"mValue")
            .KeyValue(L"HxcppdbgModelData");
}