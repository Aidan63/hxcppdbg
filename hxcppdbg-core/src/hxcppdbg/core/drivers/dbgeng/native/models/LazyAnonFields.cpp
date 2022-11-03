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
    return anon.CallMethod(L"Count").As<int>();
}

hxcppdbg::core::drivers::dbgeng::native::NativeModelData hxcppdbg::core::drivers::dbgeng::native::models::LazyAnonFields::get(const String _name)
{
    return anon.CallMethod(L"Get", std::wstring(_name.wchar_str())).As<hxcppdbg::core::drivers::dbgeng::native::NativeModelData>();
}

hxcppdbg::core::drivers::dbgeng::native::NativeModelData hxcppdbg::core::drivers::dbgeng::native::models::LazyAnonFields::at(const int _index)
{
    return anon.CallMethod(L"At", _index).As<hxcppdbg::core::drivers::dbgeng::native::NativeModelData>();
}