#include <hxcpp.h>

#include "NativeModelData.hpp"
#include "models/enums/ModelEnumObj.hpp"
#include "models/LazyEnumArguments.hpp"
#include "fmt/xchar.h"

hxcppdbg::core::drivers::dbgeng::native::models::enums::ModelEnumObj::ModelEnumObj(String _typeName, Dynamic _typeData)
    : type(_typeData), hxcppdbg::core::drivers::dbgeng::native::models::extensions::HxcppdbgExtensionModel(_typeName.wc_str())
{
    //
}

Debugger::DataModel::ClientEx::Object hxcppdbg::core::drivers::dbgeng::native::models::enums::ModelEnumObj::getHxcppdbgModelData(const Debugger::DataModel::ClientEx::Object& object)
{
    return
        hxcppdbg::core::drivers::dbgeng::native::NativeModelData_obj::HxEnum(
            type,
            String::create(object.FieldValue(L"_hx_tag").KeyValue(L"String").As<std::wstring>().c_str()),
            new hxcppdbg::core::drivers::dbgeng::native::models::LazyEnumArguments(object));
}