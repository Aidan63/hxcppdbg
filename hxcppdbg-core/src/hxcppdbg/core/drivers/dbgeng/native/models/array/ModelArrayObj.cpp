#include <hxcpp.h>

#include "models/LazyArray.hpp"
#include "models/array/ModelArrayObj.hpp"
#include "models/extensions/Utils.hpp"
#include "fmt/xchar.h"

hxcppdbg::core::drivers::dbgeng::native::models::array::ModelArrayObj::ModelArrayObj()
    : hxcppdbg::core::drivers::dbgeng::native::models::extensions::HxcppdbgExtensionModel(std::wstring(L"Array_obj<*>"))
{
    AddMethod(L"At", this, &hxcppdbg::core::drivers::dbgeng::native::models::array::ModelArrayObj::at);
    AddMethod(L"Count", this, &hxcppdbg::core::drivers::dbgeng::native::models::array::ModelArrayObj::count);
}

Debugger::DataModel::ClientEx::Object hxcppdbg::core::drivers::dbgeng::native::models::array::ModelArrayObj::getHxcppdbgModelData(const Debugger::DataModel::ClientEx::Object& _object)
{
    return
        hxcppdbg::core::drivers::dbgeng::native::NativeModelData_obj::HxArray(
            new hxcppdbg::core::drivers::dbgeng::native::models::LazyArray(_object));
}

hxcppdbg::core::drivers::dbgeng::native::NativeModelData hxcppdbg::core::drivers::dbgeng::native::models::array::ModelArrayObj::at(const Debugger::DataModel::ClientEx::Object& _object, const int _index)
{
    auto paramName = _object.Type().GenericArguments()[0].Name();
    auto paramSize = _object.FromExpressionEvaluation(USE_CURRENT_HOST_CONTEXT, fmt::to_wstring(fmt::format(L"sizeof({0})", paramName))).As<int>();
    auto expr      = fmt::to_wstring(fmt::format(L"({0}*)(mBase + {1})", paramName, _index * paramSize));
    auto element   = _object.FromBindingExpressionEvaluation(USE_CURRENT_HOST_CONTEXT, _object, expr).Dereference().GetValue();

    return
        element.Type().IsIntrinsic()
            ? hxcppdbg::core::drivers::dbgeng::native::models::extensions::intrinsicObjectToHxcppdbgModelData(element)
            : element.KeyValue(L"HxcppdbgModelData").As<hxcppdbg::core::drivers::dbgeng::native::NativeModelData>();
}

int hxcppdbg::core::drivers::dbgeng::native::models::array::ModelArrayObj::count(const Debugger::DataModel::ClientEx::Object& _object)
{
    return _object.FieldValue(L"length").As<int>();
}