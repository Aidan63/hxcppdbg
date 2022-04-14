#include <hxcpp.h>

#include "models/map/ModelHashElement.hpp"
#include "models/extensions/Utils.hpp"

#ifndef INCLUDED_hxcppdbg_core_model_ModelData
#include <hxcppdbg/core/model/ModelData.h>
#endif

#ifndef INCLUDED_hxcppdbg_core_model_Model
#include <hxcppdbg/core/model/Model.h>
#endif

hxcppdbg::core::drivers::dbgeng::native::models::map::ModelHashElement::ModelHashElement(std::wstring signature)
    : hxcppdbg::core::drivers::dbgeng::native::models::extensions::HxcppdbgExtensionModel(signature)
{
    AddStringDisplayableFunction(this, &ModelHashElement::getDisplayString);
    AddGeneratorFunction(this, &ModelHashElement::getIterator);
}

std::wstring hxcppdbg::core::drivers::dbgeng::native::models::map::ModelHashElement::getDisplayString(const Debugger::DataModel::ClientEx::Object& object, const Debugger::DataModel::ClientEx::Metadata& metadata)
{
    auto key     = object.FieldValue(L"key").TryToDisplayString().value_or(std::wstring(L"unable to read key"));
    auto value   = object.FieldValue(L"value").TryToDisplayString().value_or(std::wstring(L"unable to read key"));
    auto nextPtr = object.FieldValue(L"next");

    auto output = std::wstring();
    output.append(L"{ ");
    output.append(key);
    output.append(L" => ");
    output.append(value);
    output.append(L" }");

    if (nextPtr.As<ULONG64>() != NULL)
    {
        output.append(L", ");

        auto next    = nextPtr.Dereference().GetValue();
        auto display = next.TryToDisplayString().value_or(std::wstring(L"{ unable to read element }"));
        
        output.append(display);
    }

    return output;
}

hxcppdbg::core::model::ModelData hxcppdbg::core::drivers::dbgeng::native::models::map::ModelHashElement::getHxcppdbgModelData(const Debugger::DataModel::ClientEx::Object& object)
{
    throw std::exception("");
}

std::experimental::generator<hxcppdbg::core::model::Model> hxcppdbg::core::drivers::dbgeng::native::models::map::ModelHashElement::getIterator(const Debugger::DataModel::ClientEx::Object& object)
{
    auto nextPtr = ULONG64{ NULL };
    auto current = object;

    while (true)
    {
        auto key       = current.FieldValue(L"key");
        auto keyData   = key.Type().IsIntrinsic()
            ? hxcppdbg::core::drivers::dbgeng::native::models::extensions::intrinsicObjectToHxcppdbgModelData(key)
            : key.As<hxcppdbg::core::model::ModelData>();

        auto value     = current.FieldValue(L"value");
        auto valueData = value.Type().IsIntrinsic()
            ? hxcppdbg::core::drivers::dbgeng::native::models::extensions::intrinsicObjectToHxcppdbgModelData(value)
            : value.As<hxcppdbg::core::model::ModelData>();

        auto model = hxcppdbg::core::model::Model_obj::__new(keyData, valueData);

        co_yield(model);

        auto next = current.FieldValue(L"next");
        if (next.As<ULONG64>() == NULL)
        {
            break;
        }

        current = next.Dereference().GetValue();
    }
}