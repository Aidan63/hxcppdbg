#include <hxcpp.h>

#include "models/map/ModelIntHash.hpp"
#include "models/LazyMap.hpp"

hxcppdbg::core::drivers::dbgeng::native::models::map::ModelIntHash::ModelIntHash()
    : hxcppdbg::core::drivers::dbgeng::native::models::map::ModelHash(L"hx::TIntElement<*>")
{
    AddMethod(L"Hash", this, &ModelIntHash::hash);
    AddMethod(L"Check", this, &ModelIntHash::check);
}

Debugger::DataModel::ClientEx::Object hxcppdbg::core::drivers::dbgeng::native::models::map::ModelIntHash::getHxcppdbgModelData(const Debugger::DataModel::ClientEx::Object& _object)
{
    return
        hxcppdbg::core::drivers::dbgeng::native::NativeModelData_obj::HxIntMap(
            new hxcppdbg::core::drivers::dbgeng::native::models::LazyMap(_object));
}

bool hxcppdbg::core::drivers::dbgeng::native::models::map::ModelIntHash::check(const Debugger::DataModel::ClientEx::Object&, const int _currentKey, const int _targetKey) const
{
    return _currentKey == _targetKey;
}

unsigned int hxcppdbg::core::drivers::dbgeng::native::models::map::ModelIntHash::hash(const Debugger::DataModel::ClientEx::Object&, const int _key) const
{
    return _key;
}