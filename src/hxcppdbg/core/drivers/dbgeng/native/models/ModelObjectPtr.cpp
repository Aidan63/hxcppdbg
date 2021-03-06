#include <hxcpp.h>

#include "models/ModelObjectPtr.hpp"

#ifndef INCLUDED_hxcppdbg_core_model_ModelData
#include <hxcppdbg/core/model/ModelData.h>
#endif

#ifndef INCLUDED_hxcppdbg_core_model_Model
#include <hxcppdbg/core/model/Model.h>
#endif

hxcppdbg::core::drivers::dbgeng::native::models::ModelObjectPtr::ModelObjectPtr(std::wstring signature)
    : extensions::HxcppdbgExtensionModel(signature)
{
    AddStringDisplayableFunction(this, &hxcppdbg::core::drivers::dbgeng::native::models::ModelObjectPtr::getDisplayString);
}

std::wstring hxcppdbg::core::drivers::dbgeng::native::models::ModelObjectPtr::getDisplayString(const Debugger::DataModel::ClientEx::Object& _array, const Debugger::DataModel::ClientEx::Metadata& _metadata)
{
    auto mptr = _array.FieldValue(L"mPtr");
    auto obj  = mptr.Dereference().GetValue().TryCastToRuntimeType();
    auto str  = obj.TryToDisplayString().value_or(std::wstring(L"unable to display object"));

    return str;
}

hxcppdbg::core::model::ModelData hxcppdbg::core::drivers::dbgeng::native::models::ModelObjectPtr::getHxcppdbgModelData(const Debugger::DataModel::ClientEx::Object& object)
{
    auto pointee =
        object
            .FieldValue(L"mPtr")
            .Dereference()
            .GetValue()
            .TryCastToRuntimeType();
    auto name =
        pointee
            .Type()
            .Name();

    return
        pointee
            .KeyValue(L"HxcppdbgModelData")
            .As<hxcppdbg::core::model::ModelData>();
}