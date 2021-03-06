#include <hxcpp.h>

#include "models/anon/ModelAnonObj.hpp"

#ifndef INCLUDED_hxcppdbg_core_model_ModelData
#include <hxcppdbg/core/model/ModelData.h>
#endif

#ifndef INCLUDED_hxcppdbg_core_model_Model
#include <hxcppdbg/core/model/Model.h>
#endif

hxcppdbg::core::drivers::dbgeng::native::models::anon::ModelAnonObj::ModelAnonObj()
    : hxcppdbg::core::drivers::dbgeng::native::models::extensions::HxcppdbgExtensionModel(std::wstring(L"hx::Anon_obj"))
{
    //
}

hxcppdbg::core::model::ModelData hxcppdbg::core::drivers::dbgeng::native::models::anon::ModelAnonObj::getHxcppdbgModelData(const Debugger::DataModel::ClientEx::Object& object)
{
    auto output = Array<hxcppdbg::core::model::Model>(0, 0);

    // Fields present when anon object was created.
    auto pointer     = object.FromBindingExpressionEvaluation(USE_CURRENT_HOST_CONTEXT, object, L"(hx::Anon_obj::VariantKey *)(self + 1)");
    auto fixedFields = object.FieldValue(L"mFixedFields").As<int>();
    for (auto i = 0; i < fixedFields; i++)
    {
        output.Add(pointer.Dereference().GetValue().KeyValue(L"HxcppdbgModel").As<hxcppdbg::core::model::Model>());

        pointer++;
    }

    // Fields which were added after creation.
    auto ptr = object.FieldValue(L"mFields").FieldValue(L"mPtr");
    if (ptr.As<ULONG64>() != NULL)
    {
        auto hash =
            ptr
                .Dereference()
                .GetValue()
                .TryCastToRuntimeType();

        auto type = hash.Type().Name();

        for (auto&& element : hash)
        {
            output.Add(element.As<hxcppdbg::core::model::Model>());
        }
    }

    return hxcppdbg::core::model::ModelData_obj::MAnon(output);
}