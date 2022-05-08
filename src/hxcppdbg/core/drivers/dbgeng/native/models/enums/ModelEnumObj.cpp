#include <hxcpp.h>

#include "models/enums/ModelEnumObj.hpp"
#include "fmt/xchar.h"

#ifndef INCLUDED_hxcppdbg_core_model_ModelData
#include <hxcppdbg/core/model/ModelData.h>
#endif

#ifndef INCLUDED_hxcppdbg_core_model_Model
#include <hxcppdbg/core/model/Model.h>
#endif

#ifndef INCLUDED_hxcppdbg_core_sourcemap_GeneratedType
#include <hxcppdbg/core/sourcemap/GeneratedType.h>
#endif

hxcppdbg::core::drivers::dbgeng::native::models::enums::ModelEnumObj::ModelEnumObj(hxcppdbg::core::sourcemap::GeneratedType _type)
    : type(_type), hxcppdbg::core::drivers::dbgeng::native::models::extensions::HxcppdbgExtensionModel(_type->cpp.wc_str())
{
    //
}

hxcppdbg::core::model::ModelData hxcppdbg::core::drivers::dbgeng::native::models::enums::ModelEnumObj::getHxcppdbgModelData(const Debugger::DataModel::ClientEx::Object& object)
{
    auto tag        = object.FieldValue(L"_hx_tag").KeyValue(L"String").As<std::wstring>();
    auto fieldCount = object.FieldValue(L"mFixedFields").As<int>();
    auto fields     = Array<Dynamic>(fieldCount, fieldCount);

    if (fieldCount == 0)
    {
        return hxcppdbg::core::model::ModelData_obj::MEnum(type, String::create(tag.c_str()), fields);
    }

    auto variants = object.FromBindingExpressionEvaluation(USE_CURRENT_HOST_CONTEXT, object, L"(cpp::Variant *)(self + 1)");
    for (auto i = 0; i < fieldCount; i++)
    {
        fields[i] = variants.Dereference().GetValue().KeyValue(L"HxcppdbgModelData").As<hxcppdbg::core::model::ModelData>();

        variants++;
    }

    return hxcppdbg::core::model::ModelData_obj::MEnum(type, String::create(tag.c_str()), fields);
}