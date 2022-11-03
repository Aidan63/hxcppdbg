#include <hxcpp.h>
#include "LazyClassFields.hpp"
#include "NativeModelData.hpp"

hxcppdbg::core::drivers::dbgeng::native::models::LazyClassFields::LazyClassFields(const Debugger::DataModel::ClientEx::Object& _cls)
    : cls(Debugger::DataModel::ClientEx::Object(_cls))
{
    //
}

int hxcppdbg::core::drivers::dbgeng::native::models::LazyClassFields::count()
{
    return cls.CallMethod(L"Count").As<int>();
}

hxcppdbg::core::drivers::dbgeng::native::NativeModelData hxcppdbg::core::drivers::dbgeng::native::models::LazyClassFields::at(const int _index)
{
    return cls.CallMethod(L"At", _index).As<hxcppdbg::core::drivers::dbgeng::native::NativeModelData>();
}

hxcppdbg::core::drivers::dbgeng::native::NativeModelData hxcppdbg::core::drivers::dbgeng::native::models::LazyClassFields::get(const String _field)
{
    return cls.CallMethod(L"Get", std::wstring(_field.wchar_str())).As<hxcppdbg::core::drivers::dbgeng::native::NativeModelData>();
}