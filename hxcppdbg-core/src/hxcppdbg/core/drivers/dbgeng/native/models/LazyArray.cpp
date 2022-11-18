#include <hxcpp.h>
#include "LazyArray.hpp"
#include "NativeModelData.hpp"

hxcppdbg::core::drivers::dbgeng::native::models::LazyArray::LazyArray(const Debugger::DataModel::ClientEx::Object& _object)
    : IDbgEngIndexable<hxcppdbg::core::drivers::dbgeng::native::NativeModelData>(_object)
    , paramSize(std::nullopt)
    , paramName(std::nullopt)
{
    //
}

int hxcppdbg::core::drivers::dbgeng::native::models::LazyArray::getParamSize()
{
    if (!paramSize.has_value())
    {
        paramSize.emplace(object.KeyValue(L"ParamSize").As<int>());
    }

    return paramSize.value();
}

std::wstring hxcppdbg::core::drivers::dbgeng::native::models::LazyArray::getParamName()
{
    if (!paramName.has_value())
    {
        paramName.emplace(object.KeyValue(L"ParamName").As<std::wstring>());
    }

    return paramName.value();
}

int hxcppdbg::core::drivers::dbgeng::native::models::LazyArray::count()
{
    try
    {
        return object.CallMethod(L"Count").As<int>();
    }
    catch (const std::exception& exn)
    {
        hx::Throw(String::create(exn.what()));
    }
}

hxcppdbg::core::drivers::dbgeng::native::NativeModelData hxcppdbg::core::drivers::dbgeng::native::models::LazyArray::at(const int _index)
{
    try
    {
        return object.CallMethod(L"At", _index, getParamName(), getParamSize()).As<hxcppdbg::core::drivers::dbgeng::native::NativeModelData>();
    }
    catch (const std::exception& exn)
    {
        hx::Throw(String::create(exn.what()));
    }
}