#include <hxcpp.h>
#include "LazyAnonFields.hpp"
#include "NativeModelData.hpp"

hxcppdbg::core::drivers::dbgeng::native::models::LazyAnonFields::LazyAnonFields(const Debugger::DataModel::ClientEx::Object& _object)
    : anon(Debugger::DataModel::ClientEx::Object(_object))
{
    //
}

int hxcppdbg::core::drivers::dbgeng::native::models::LazyAnonFields::count()
{
    try
    {
        return anon.CallMethod(L"Count").As<int>();
    }
    catch (const std::exception& exn)
    {
        hx::Throw(String::create(exn.what()));
    }
}

hxcppdbg::core::drivers::dbgeng::native::NativeModelData hxcppdbg::core::drivers::dbgeng::native::models::LazyAnonFields::get(const String _name)
{
    try
    {
        return anon.CallMethod(L"Get", std::wstring(_name.wchar_str())).As<hxcppdbg::core::drivers::dbgeng::native::NativeModelData>();
    }
    catch (const std::exception& exn)
    {
        hx::Throw(String::create(exn.what()));
    }
    
}

hxcppdbg::core::drivers::dbgeng::native::NativeModelData hxcppdbg::core::drivers::dbgeng::native::models::LazyAnonFields::at(const int _index)
{
    try
    {
        return anon.CallMethod(L"At", _index).As<hxcppdbg::core::drivers::dbgeng::native::NativeModelData>();
    }
    catch (const std::exception& exn)
    {
        hx::Throw(String::create(exn.what()));
    }
}