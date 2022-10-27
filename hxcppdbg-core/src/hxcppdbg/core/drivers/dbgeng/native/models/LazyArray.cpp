#include <hxcpp.h>
#include "LazyArray.hpp"
#include "NativeModelData.hpp"

hxcppdbg::core::drivers::dbgeng::native::models::LazyArray::LazyArray(const Debugger::DataModel::ClientEx::Object& _object)
    : array(Debugger::DataModel::ClientEx::Object(_object))
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