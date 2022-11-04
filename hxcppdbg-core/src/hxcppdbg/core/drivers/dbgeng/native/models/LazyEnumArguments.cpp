#include <hxcpp.h>
#include "LazyEnumArguments.hpp"
#include "NativeModelData.hpp"
#include "fmt/xchar.h"

hxcppdbg::core::drivers::dbgeng::native::models::LazyEnumArguments::LazyEnumArguments(const Debugger::DataModel::ClientEx::Object& _object)
    : object(Debugger::DataModel::ClientEx::Object(_object))
{
    //
}

int hxcppdbg::core::drivers::dbgeng::native::models::LazyEnumArguments::count()
{
    try
    {
        return object.FieldValue(L"mFixedFields").As<int>();
    }
    catch (const std::exception& exn)
    {
        hx::Throw(String::create(exn.what()));
    }
}

hxcppdbg::core::drivers::dbgeng::native::NativeModelData hxcppdbg::core::drivers::dbgeng::native::models::LazyEnumArguments::at(const int _index)
{
    try
    {
        return
            object
                .FromBindingExpressionEvaluation(USE_CURRENT_HOST_CONTEXT, object, fmt::to_wstring(fmt::format(L"(cpp::Variant *)(self + 1 + {0})", _index)))
                .Dereference()
                .GetValue()
                .KeyValue(L"HxcppdbgModelData")
                .As<hxcppdbg::core::drivers::dbgeng::native::NativeModelData>();
    }
    catch (const std::exception& exn)
    {
        hx::Throw(String::create(exn.what()));
    }
}