#include <hxcpp.h>

#include "models/array/ModelArray.hpp"
#include "models/ModelStorage.hpp"
#include "fmt/format.h"

#ifndef INCLUDED_hxcppdbg_core_model_Model
#include <hxcppdbg/core/model/Model.h>
#endif

#ifndef INCLUDED_hxcppdbg_core_model_ModelData
#include <hxcppdbg/core/model/ModelData.h>
#endif

bool hxcppdbg::core::drivers::lldb::native::models::array::setArrayHxcppdbgModelData(::lldb::SBValue object, ::lldb::SBTypeSummaryOptions options, ::lldb::SBStream& stream)
{
    auto lengthMember = object.GetChildMemberWithName("length");
    if (!lengthMember.IsValid())
    {
        return false;
    }

    auto type = object.GetType();
    if (!type.IsValid())
    {
        return false;
    }

    auto element = type.GetTemplateArgumentType(0);
    if (!element.IsValid())
    {
        return false;
    }

    auto elementName = element.GetName();
    auto elementSize = element.GetByteSize();
    auto length      = lengthMember.GetValueAsSigned();
    auto output      = Array<hxcppdbg::core::model::ModelData>(length, length);

    for (auto i = 0; i < length; i++)
    {
        auto expr      = fmt::format("({0}*)(mBase + {1})", elementName, i * elementSize);
        auto evaluated = object.EvaluateExpression(expr.c_str());

        if (!evaluated.IsValid())
        {
            return false;
        }

        auto dereferenced = evaluated.Dereference();
        if (!dereferenced.IsValid())
        {
            return false;
        }

        output[i] = hxcppdbg::core::drivers::lldb::native::models::valueAsModel(dereferenced);
    }

    *hxcppdbg::core::drivers::lldb::native::models::currentModel = hxcppdbg::core::model::ModelData_obj::MArray(output).mPtr;

    stream.Printf("hxcppdbg");

    return true;
}

bool hxcppdbg::core::drivers::lldb::native::models::array::setVirtualArrayHxcppdbgModelData(::lldb::SBValue object, ::lldb::SBTypeSummaryOptions options, ::lldb::SBStream& stream)
{
    auto baseMember = object.GetChildMemberWithName("base");
    if (!baseMember.IsValid())
    {
        return false;
    }

    return setArrayHxcppdbgModelData(baseMember, options, stream);
}