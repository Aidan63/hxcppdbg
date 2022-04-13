#include <hxcpp.h>

#include "models/array/ModelArrayObj.hpp"
#include "models/extensions/Utils.hpp"
#include "fmt/xchar.h"

#ifndef INCLUDED_hxcppdbg_core_model_ModelData
#include <hxcppdbg/core/model/ModelData.h>
#endif

#ifndef INCLUDED_hxcppdbg_core_model_Model
#include <hxcppdbg/core/model/Model.h>
#endif

hxcppdbg::core::drivers::dbgeng::native::models::array::ModelArrayObj::ModelArrayObj()
    : hxcppdbg::core::drivers::dbgeng::native::models::extensions::HxcppdbgExtensionModel(L"Array_obj<*>")
{
    AddStringDisplayableFunction(this, &hxcppdbg::core::drivers::dbgeng::native::models::array::ModelArrayObj::getDisplayString);
}

std::wstring hxcppdbg::core::drivers::dbgeng::native::models::array::ModelArrayObj::getDisplayString(const Debugger::DataModel::ClientEx::Object& object, const Debugger::DataModel::ClientEx::Metadata& metadata)
{
    auto length      = object.FieldValue(L"length").As<int>();
    auto allocated   = object.FieldValue(L"mAlloc").As<int>();
    auto paramName   = object.Type().GenericArguments()[0].Name();
    auto elementSize = object.FromExpressionEvaluation(USE_CURRENT_HOST_CONTEXT, fmt::to_wstring(fmt::format(L"sizeof({0})", paramName))).As<int>();
    auto output      = fmt::to_wstring(fmt::format(L"( length = {0}, allocated = {1} ) [ ", length, allocated));

    for (auto i = 0; i < length; i++)
    {
        auto expr    = fmt::to_wstring(fmt::format(L"({0}*)(mBase + {1})", paramName, i * elementSize));
        auto element = object.FromBindingExpressionEvaluation(USE_CURRENT_HOST_CONTEXT, object, expr).Dereference().GetValue();
        auto display = element.TryToDisplayString().value_or(L"( unable to read element )");

        output.append(display);
        output.append(i < length - 1 ? L", " : L" ");
    }

    output.append(L"]");

    return output;
}

hxcppdbg::core::model::ModelData hxcppdbg::core::drivers::dbgeng::native::models::array::ModelArrayObj::getHxcppdbgModelData(const Debugger::DataModel::ClientEx::Object& object)
{
    auto length      = object.FieldValue(L"length").As<int>();
    auto paramName   = object.Type().GenericArguments()[0].Name();
    auto elementSize = object.FromExpressionEvaluation(USE_CURRENT_HOST_CONTEXT, fmt::to_wstring(fmt::format(L"sizeof({0})", paramName))).As<int>();
    auto output      = Array<hxcppdbg::core::model::ModelData>(0, 0);

    for (auto i = 0; i < length; i++)
    {
        auto expr    = fmt::to_wstring(fmt::format(L"({0}*)(mBase + {1})", paramName, i * elementSize));
        auto element = object.FromBindingExpressionEvaluation(USE_CURRENT_HOST_CONTEXT, object, expr).Dereference().GetValue();
        auto model   = element.Type().IsIntrinsic()
            ? hxcppdbg::core::drivers::dbgeng::native::models::extensions::intrinsicObjectToHxcppdbgModelData(element)
            : element.KeyValue(L"HxcppdbgModelData").As<hxcppdbg::core::model::ModelData>();

        output.Add(model);
    }

    return hxcppdbg::core::model::ModelData_obj::MArray(output);
}