#include <hxcpp.h>
#include "LazyAnonFields.hpp"
#include "NativeModelData.hpp"

hxcppdbg::core::drivers::dbgeng::native::models::LazyAnonFields::LazyAnonFields(const Debugger::DataModel::ClientEx::Object& _object)
    : anon(Debugger::DataModel::ClientEx::Object(_object))
{
    //
}

int hxcppdbg::core::drivers::dbgeng::native::models::LazyAnonFields::count() const
{
    return anon.CallMethod(L"Count").As<int>();
}

hxcppdbg::core::drivers::dbgeng::native::NativeModelData hxcppdbg::core::drivers::dbgeng::native::models::LazyAnonFields::field(const String _name) const
{
    return anon.CallMethod(L"Field", std::wstring(_name.wchar_str())).As<hxcppdbg::core::drivers::dbgeng::native::NativeModelData>();
}