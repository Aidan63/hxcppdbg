#include <hxcpp.h>

#include "models/LazyMap.hpp"
#include "models/map/hashes/ModelDynamicHash.hpp"

hxcppdbg::core::drivers::dbgeng::native::models::map::hashes::ModelDynamicHash::ModelDynamicHash()
    : hxcppdbg::core::drivers::dbgeng::native::models::map::hashes::ModelHash(std::wstring(L"hx::TDynamicElement<*>"))
{
    //
}

Debugger::DataModel::ClientEx::Object hxcppdbg::core::drivers::dbgeng::native::models::map::hashes::ModelDynamicHash::getHxcppdbgModelData(const Debugger::DataModel::ClientEx::Object& _object)
{
    return
        hxcppdbg::core::drivers::dbgeng::native::NativeModelData_obj::HxDynamicMap(
            new hxcppdbg::core::drivers::dbgeng::native::models::LazyDynamicMap(_object));
}