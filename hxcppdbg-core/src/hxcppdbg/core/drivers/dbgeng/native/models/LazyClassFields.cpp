#include <hxcpp.h>
#include "LazyClassFields.hpp"
#include "NativeModelData.hpp"
#include "extensions/AnonBoxer.hpp"

hxcppdbg::core::drivers::dbgeng::native::models::LazyClassFields::LazyClassFields(const Debugger::DataModel::ClientEx::Object& _cls)
    : IDbgEngKeyable<String, Dynamic>(_cls)
{
    //
}

int hxcppdbg::core::drivers::dbgeng::native::models::LazyClassFields::count()
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

Dynamic hxcppdbg::core::drivers::dbgeng::native::models::LazyClassFields::at(const int _index)
{
    try
    {
        return extensions::AnonBoxer::Unbox(object.CallMethod(L"At", _index));
    }
    catch (const std::exception& exn)
    {
        hx::Throw(String::create(exn.what()));
    }
}

hxcppdbg::core::drivers::dbgeng::native::NativeModelData hxcppdbg::core::drivers::dbgeng::native::models::LazyClassFields::get(const String _field)
{
    try
    {
        return object.CallMethod(L"Get", std::wstring(_field.wchar_str())).As<hxcppdbg::core::drivers::dbgeng::native::NativeModelData>();
    }
    catch (const std::exception& exn)
    {
        hx::Throw(String::create(exn.what()));
    }
}