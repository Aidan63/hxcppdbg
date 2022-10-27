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
    return map->CallMethod(L"Count").As<int>();
}

hxcppdbg::core::drivers::dbgeng::native::NativeModelData hxcppdbg::core::drivers::dbgeng::native::models::LazyMap::child(const int _index) const
{
    return map->CallMethod(L"At").As<hxcppdbg::core::drivers::dbgeng::native::NativeModelData>();
}