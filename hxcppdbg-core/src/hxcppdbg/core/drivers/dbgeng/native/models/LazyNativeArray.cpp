#include <hxcpp.h>
#include "LazyNativeArray.hpp"
#include "NativeModelData.hpp"
#include "extensions/Utils.hpp"

hxcppdbg::core::drivers::dbgeng::native::models::LazyNativeArray::LazyNativeArray(
    const Debugger::DataModel::ClientEx::Object& _object,
    const std::wstring& _type,
    const int& _size)
    : type(_type), size(_size), IDbgEngIndexable(_object)
{
    //
}

int hxcppdbg::core::drivers::dbgeng::native::models::LazyNativeArray::count()
{
    return size;
}

hxcppdbg::core::drivers::dbgeng::native::NativeModelData hxcppdbg::core::drivers::dbgeng::native::models::LazyNativeArray::at(const int _index)
{
    try
    {
        return extensions::objectToHxcppdbgModelData(object[_index].GetValue());
    }
    catch(const std::exception& exn)
    {
        hx::Throw(String::create(exn.what()));
    }
}