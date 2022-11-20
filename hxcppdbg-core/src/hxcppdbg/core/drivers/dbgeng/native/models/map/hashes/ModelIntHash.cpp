#include <hxcpp.h>

#include "models/LazyMap.hpp"
#include "models/map/hashes/ModelIntHash.hpp"

hxcppdbg::core::drivers::dbgeng::native::models::map::hashes::ModelIntHash::ModelIntHash()
    : hxcppdbg::core::drivers::dbgeng::native::models::map::hashes::ModelHash(std::wstring(L"hx::TIntElement<*>"))
{
    //
}

Debugger::DataModel::ClientEx::Object hxcppdbg::core::drivers::dbgeng::native::models::map::hashes::ModelIntHash::getHxcppdbgModelData(const Debugger::DataModel::ClientEx::Object& _object)
{
    return
        hxcppdbg::core::drivers::dbgeng::native::NativeModelData_obj::HxIntMap(
            new hxcppdbg::core::drivers::dbgeng::native::models::LazyIntMap(_object));
}