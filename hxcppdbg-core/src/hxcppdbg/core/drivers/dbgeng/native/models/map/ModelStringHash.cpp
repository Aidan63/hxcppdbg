#include <hxcpp.h>

#include "models/map/ModelStringHash.hpp"
#include "models/LazyMap.hpp"

hxcppdbg::core::drivers::dbgeng::native::models::map::ModelStringHash::ModelStringHash()
    : hxcppdbg::core::drivers::dbgeng::native::models::map::ModelHash(L"hx::TStringElement<*>")
{
    AddMethod(L"Hash", this, &ModelStringHash::hash);
    AddMethod(L"Check", this, &ModelStringHash::check);
}

Debugger::DataModel::ClientEx::Object hxcppdbg::core::drivers::dbgeng::native::models::map::ModelStringHash::getHxcppdbgModelData(const Debugger::DataModel::ClientEx::Object& _object)
{
    return
        hxcppdbg::core::drivers::dbgeng::native::NativeModelData_obj::HxStringMap(
            new hxcppdbg::core::drivers::dbgeng::native::models::LazyMap(_object));
}

bool hxcppdbg::core::drivers::dbgeng::native::models::map::ModelStringHash::check(const Debugger::DataModel::ClientEx::Object&, const Debugger::DataModel::ClientEx::Object _currentKey, const std::wstring _targetKey) const
{
    return _currentKey.KeyValue(L"String").As<std::wstring>() == _targetKey;
}

unsigned int hxcppdbg::core::drivers::dbgeng::native::models::map::ModelStringHash::hash(const Debugger::DataModel::ClientEx::Object&, const std::wstring _key) const
{
    return String::create(_key.c_str()).hash();
}