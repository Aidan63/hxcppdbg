#include <hxcpp.h>
#include <SBAddress.h>

#include "models/dynamic/ModelDynamic.hpp"
#include "models/ModelStorage.hpp"

#ifndef INCLUDED_hxcppdbg_core_model_Model
#include <hxcppdbg/core/model/Model.h>
#endif

#ifndef INCLUDED_hxcppdbg_core_model_ModelData
#include <hxcppdbg/core/model/ModelData.h>
#endif

bool hxcppdbg::core::drivers::lldb::native::models::dynamic::setDynamicHxcppdbgModelData(::lldb::SBValue object, ::lldb::SBTypeSummaryOptions, ::lldb::SBStream& stream)
{
    auto mPtrMember = object.GetChildMemberWithName("mPtr");
    if (!mPtrMember.IsValid())
    {
        return false;
    }

    auto address = mPtrMember.GetAddress();
    if (!address.IsValid())
    {
        return false;
    }

    if (address.GetOffset() == 0)
    {
        *hxcppdbg::core::drivers::lldb::native::models::currentModel = hxcppdbg::core::model::ModelData_obj::MNull.mPtr;

        stream.Printf("hxcppdbg");

        return true;
    }

    auto dereferenced = mPtrMember.Dereference();
    if (!dereferenced.IsValid())
    {
        return false;
    }

    auto summary = dereferenced.GetSummary();
    if (summary && std::string(summary) == std::string("hxcppdbg"))
    {
        stream.Printf("hxcppdbg");

        return true;
    }
    else
    {
        return false;
    }
}

bool hxcppdbg::core::drivers::lldb::native::models::dynamic::setBoxedHxcppdbgModelData(::lldb::SBValue object, ::lldb::SBTypeSummaryOptions, ::lldb::SBStream& stream)
{
    auto value = object.GetChildMemberWithName("mValue");
    if (!value.IsValid())
    {
        return false;
    }

    auto type  = value.GetType();
    auto basic = type.GetBasicType();

    switch (basic)
    {
        case ::lldb::BasicType::eBasicTypeInvalid:
            {
                auto summary = value.GetSummary();
                if (summary && std::string(summary) == std::string("hxcppdbg"))
                {
                    stream.Printf("hxcppdbg");

                    return true;
                }
                else
                {
                    return false;
                }
            }

        case ::lldb::BasicType::eBasicTypeChar:
        case ::lldb::BasicType::eBasicTypeSignedChar:
        case ::lldb::BasicType::eBasicTypeWChar:
        case ::lldb::BasicType::eBasicTypeSignedWChar:
        case ::lldb::BasicType::eBasicTypeShort:
        case ::lldb::BasicType::eBasicTypeInt:
        case ::lldb::BasicType::eBasicTypeLong:
        case ::lldb::BasicType::eBasicTypeLongLong:
        case ::lldb::BasicType::eBasicTypeChar16:
        case ::lldb::BasicType::eBasicTypeChar32:
            {
                auto error  = ::lldb::SBError();
                auto result = value.GetValueAsSigned(error);
                if (error.Fail())
                {
                    *currentModel = hxcppdbg::core::model::ModelData_obj::MNull.mPtr;
                }
                else
                {
                    *currentModel = hxcppdbg::core::model::ModelData_obj::MInt(static_cast<int>(result)).mPtr;
                }
            }
        
        case ::lldb::BasicType::eBasicTypeUnsignedChar:
        case ::lldb::BasicType::eBasicTypeUnsignedWChar:
        case ::lldb::BasicType::eBasicTypeUnsignedShort:
        case ::lldb::BasicType::eBasicTypeUnsignedInt:
        case ::lldb::BasicType::eBasicTypeUnsignedLong:
        case ::lldb::BasicType::eBasicTypeUnsignedLongLong:
            {
                auto error  = ::lldb::SBError();
                auto result = value.GetValueAsUnsigned(error);
                if (error.Fail())
                {
                    *currentModel = hxcppdbg::core::model::ModelData_obj::MNull.mPtr;
                }
                else
                {
                    *currentModel = hxcppdbg::core::model::ModelData_obj::MInt(static_cast<int>(result)).mPtr;
                }
            }

        case ::lldb::BasicType::eBasicTypeBool:
            {
                auto error  = ::lldb::SBError();
                auto result = value.GetValueAsUnsigned(error);
                if (error.Fail())
                {
                    *currentModel = hxcppdbg::core::model::ModelData_obj::MNull.mPtr;
                }
                else
                {
                    *currentModel = hxcppdbg::core::model::ModelData_obj::MBool(static_cast<bool>(result)).mPtr;
                }
            }

        case ::lldb::BasicType::eBasicTypeHalf:
        case ::lldb::BasicType::eBasicTypeFloat:
        case ::lldb::BasicType::eBasicTypeDouble:
            {
                auto error  = ::lldb::SBError();
                auto result = value.GetValueAsSigned(error);
                if (error.Fail())
                {
                    *currentModel = hxcppdbg::core::model::ModelData_obj::MNull.mPtr;
                }
                else
                {
                    *currentModel = hxcppdbg::core::model::ModelData_obj::MFloat(static_cast<double>(result)).mPtr;
                }
            }

        default:
            *currentModel = hxcppdbg::core::model::ModelData_obj::MUnknown(String::create(type.GetName())).mPtr;
    }

    stream.Printf("hxcppdbg");

    return true;
}