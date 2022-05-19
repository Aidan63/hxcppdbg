#include <hxcpp.h>

#include "models/array/ModelArray.hpp"
#include "models/ModelStorage.hpp"
#include "fmt/format.h"

#include <SBError.h>

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
    auto lengthCall = object.EvaluateExpression("__length()");
    if (!lengthCall.IsValid())
    {
        return false;
    }

    auto length = lengthCall.GetValueAsSigned();
    auto output = Array<hxcppdbg::core::model::ModelData>(length, length);

    for (auto i = 0; i < length; i++)
    {
        auto evaluated = object.EvaluateExpression(fmt::format("__GetItem({0})", i).c_str());
        if (!evaluated.IsValid())
        {
            return false;
        }

        output[i] = hxcppdbg::core::drivers::lldb::native::models::valueAsModel(evaluated);
    }

    *hxcppdbg::core::drivers::lldb::native::models::currentModel = hxcppdbg::core::model::ModelData_obj::MArray(output).mPtr;

    stream.Printf("hxcppdbg");

    return true;

    // enum ArrayStore
    // {
    //     arrayNull = 0,
    //     arrayEmpty,
    //     arrayFixed,
    //     arrayBool,
    //     arrayInt,
    //     arrayFloat,
    //     arrayString,
    //     arrayObject,
    //     arrayInt64
    // };

    // auto baseMember = object.GetChildMemberWithName("base");
    // if (!baseMember.IsValid())
    // {
    //     return false;
    // }

    // auto storeMember = object.GetChildMemberWithName("store");
    // if (!storeMember.IsValid())
    // {
    //     return false;
    // }

    // switch ((ArrayStore)storeMember.GetValueAsUnsigned())
    // {
    //     case ArrayStore::arrayNull:
    //         break;

    //     case ArrayStore::arrayEmpty:
    //         break;

    //     case ArrayStore::arrayFixed:
    //         break;

    //     case ArrayStore::arrayBool:
    //         break;

    //     case ArrayStore::arrayInt:
    //         {
    //             auto ptr = baseMember.GetValueAsUnsigned();

    //             auto evaluated = object.EvaluateExpression(fmt::format("Array_obj<int>* a = (Array_obj<int>*)base").c_str());
    //             if (!evaluated.IsValid())
    //             {
    //                 return false;
    //             }
    //             else
    //             {
    //                 auto dereferenced = evaluated.Dereference();
    //                 if (!dereferenced.IsValid())
    //                 {
    //                     auto err = dereferenced.GetError().GetCString();

    //                     return false;
    //                 }
    //                 else
    //                 {
    //                     return setArrayHxcppdbgModelData(dereferenced, options, stream);
    //                 }
    //             }
    //         }

    //     case ArrayStore::arrayFloat:
    //         break;
        
    //     case ArrayStore::arrayString:
    //         break;

    //     case ArrayStore::arrayObject:
    //         break;

    //     case ArrayStore::arrayInt64:
    //         break;
    // }

    return false;
}