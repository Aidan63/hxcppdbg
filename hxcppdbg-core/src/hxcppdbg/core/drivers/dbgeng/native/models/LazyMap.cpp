#include <hxcpp.h>
#include "LazyMap.hpp"
#include "NativeModelData.hpp"

hxcppdbg::core::drivers::dbgeng::native::models::LazyMap::LazyMap(const Debugger::DataModel::ClientEx::Object& _object)
    : map(Debugger::DataModel::ClientEx::Object(_object))
{
    //
}

int hxcppdbg::core::drivers::dbgeng::native::models::LazyMap::count() const
{
    return map.CallMethod(L"Count").As<int>();
}

hxcppdbg::core::drivers::dbgeng::native::NativeModelData hxcppdbg::core::drivers::dbgeng::native::models::LazyMap::key(const int _index) const
{
    return map.CallMethod(L"Key", _index).As<hxcppdbg::core::drivers::dbgeng::native::NativeModelData>();
}

hxcppdbg::core::drivers::dbgeng::native::NativeModelData hxcppdbg::core::drivers::dbgeng::native::models::LazyMap::value(const int _key) const
{
    return map.CallMethod(L"Value", _key).As<hxcppdbg::core::drivers::dbgeng::native::NativeModelData>();
}

hxcppdbg::core::drivers::dbgeng::native::NativeModelData hxcppdbg::core::drivers::dbgeng::native::models::LazyMap::value(const String _key) const
{
    return map.CallMethod(L"Value", std::wstring(_key.wchar_str())).As<hxcppdbg::core::drivers::dbgeng::native::NativeModelData>();
}