#include <hxcpp.h>

#include "models/LazyMap.hpp"
#include "models/map/hashes/ModelStringHash.hpp"

hxcppdbg::core::drivers::dbgeng::native::models::map::hashes::ModelStringHash::ModelStringHash()
    : hxcppdbg::core::drivers::dbgeng::native::models::map::hashes::ModelHash(std::wstring(L"hx::TStringElement<*>"))
{
    //
}

Debugger::DataModel::ClientEx::Object hxcppdbg::core::drivers::dbgeng::native::models::map::hashes::ModelStringHash::getHxcppdbgModelData(const Debugger::DataModel::ClientEx::Object& _object)
{
    return
        hxcppdbg::core::drivers::dbgeng::native::NativeModelData_obj::HxStringMap(
            new hxcppdbg::core::drivers::dbgeng::native::models::LazyStringMap(_object));
}