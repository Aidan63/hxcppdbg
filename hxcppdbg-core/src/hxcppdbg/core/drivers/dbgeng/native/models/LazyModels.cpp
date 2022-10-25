#include <hxcpp.h>
#include "LazyModels.hpp"
#include "NativeModelData.hpp"

using namespace Debugger::DataModel::ClientEx;

//

hxcppdbg::core::drivers::dbgeng::native::models::LazyArray::LazyArray(const Object& _object)
    : array(Object(_object))
{
    //
}

int hxcppdbg::core::drivers::dbgeng::native::models::LazyArray::length() const
{
    return array.CallMethod(L"Length").As<int>();
}

int hxcppdbg::core::drivers::dbgeng::native::models::LazyArray::elementSize() const
{
    return array.CallMethod(L"ElementSize").As<int>();
}

hxcppdbg::core::drivers::dbgeng::native::NativeModelData hxcppdbg::core::drivers::dbgeng::native::models::LazyArray::at(const int _elementSize, const int _index) const
{
    return array.CallMethod(L"At", _elementSize, _index).As<hxcppdbg::core::drivers::dbgeng::native::NativeModelData>();
}

//

hxcppdbg::core::drivers::dbgeng::native::models::LazyMap::LazyMap()
    : map(cpp::Reference<Object>())
{
    //
}

hxcppdbg::core::drivers::dbgeng::native::models::LazyMap::LazyMap(const Object& _object)
    : map(cpp::Reference(_object))
{
    //
}

hxcppdbg::core::drivers::dbgeng::native::models::LazyMap::LazyMap(const LazyMap& _from)
    : map(cpp::Reference(_from.map))
{
    //
}

hxcppdbg::core::drivers::dbgeng::native::models::LazyMap& hxcppdbg::core::drivers::dbgeng::native::models::LazyMap::operator=(const LazyMap& _from)
{
    if (this != &_from)
    {
        map = cpp::Reference(_from.map);
    }

    return *this;
}

int hxcppdbg::core::drivers::dbgeng::native::models::LazyMap::count() const
{
    return map->CallMethod(L"Count").As<int>();
}

hxcppdbg::core::drivers::dbgeng::native::NativeModelData hxcppdbg::core::drivers::dbgeng::native::models::LazyMap::child(const int _index) const
{
    return map->CallMethod(L"At").As<hxcppdbg::core::drivers::dbgeng::native::NativeModelData>();
}