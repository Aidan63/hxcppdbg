#include <hxcpp.h>

#include "models/map/ModelHashElement.hpp"
#include "models/extensions/Utils.hpp"

#ifndef INCLUDED_hxcppdbg_core_model_ModelData
#include <hxcppdbg/core/model/ModelData.h>
#endif

#ifndef INCLUDED_hxcppdbg_core_model_Model
#include <hxcppdbg/core/model/Model.h>
#endif

using namespace Debugger::DataModel::ClientEx;
using namespace Debugger::DataModel::ProviderEx;

hxcppdbg::core::drivers::dbgeng::native::models::map::ModelHashElement::ModelHashElement(std::wstring _signature)
    : ExtensionModel(TypeSignatureExtension(_signature))
{
    AddMethod(L"Count", this, &ModelHashElement::count);
    AddMethod(L"At", this, &ModelHashElement::at);
}

int hxcppdbg::core::drivers::dbgeng::native::models::map::ModelHashElement::count(const Object& _object, const std::optional<int> _accumulated)
{
    auto count = _accumulated.value_or(1);
    auto next  = _object.FieldValue(L"next");

    return (next.As<uint64_t>() == 0UL)
        ? count
        : next.Dereference().GetValue().CallMethod(L"Count", count).As<int>();
}

hxcppdbg::core::model::Model hxcppdbg::core::drivers::dbgeng::native::models::map::ModelHashElement::at(const Object& _object, const int _index)
{
    auto current = _object;
    auto count   = _index;

    while (count > 0)
    {
        current = current.FieldValue(L"next").Dereference().GetValue();

        count--;
    }

    auto key       = current.FieldValue(L"key");
    auto keyData   = key.Type().IsIntrinsic()
        ? hxcppdbg::core::drivers::dbgeng::native::models::extensions::intrinsicObjectToHxcppdbgModelData(key)
        : key.KeyValue(L"HxcppdbgModelData").As<hxcppdbg::core::model::ModelData>();

    auto value     = current.FieldValue(L"value");
    auto valueData = value.Type().IsIntrinsic()
        ? hxcppdbg::core::drivers::dbgeng::native::models::extensions::intrinsicObjectToHxcppdbgModelData(value)
        : value.KeyValue(L"HxcppdbgModelData").As<hxcppdbg::core::model::ModelData>();

    return hxcppdbg::core::model::Model_obj::__new(keyData, valueData);
}