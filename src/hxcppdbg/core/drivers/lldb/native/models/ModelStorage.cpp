#include <hxcpp.h>
#include <SBError.h>

#include "models/ModelStorage.hpp"

#ifndef INCLUDED_hxcppdbg_core_model_ModelData
#include <hxcppdbg/core/model/ModelData.h>
#endif

#ifndef INCLUDED_hxcppdbg_core_model_Model
#include <hxcppdbg/core/model/Model.h>
#endif

#ifndef INCLUDED_hxcppdbg_core_sourcemap_GeneratedType
#include <hxcppdbg/core/sourcemap/GeneratedType.h>
#endif

hx::Object** hxcppdbg::core::drivers::lldb::native::models::currentModel = new hx::Object*(nullptr);
hx::Object** hxcppdbg::core::drivers::lldb::native::models::classLookup = new hx::Object*(nullptr);
hx::Object** hxcppdbg::core::drivers::lldb::native::models::enumLookup = new hx::Object*(nullptr);

hxcppdbg::core::model::ModelData hxcppdbg::core::drivers::lldb::native::models::valueAsModel(::lldb::SBValue object)
{
    auto type  = object.GetType();
    auto basic = type.GetBasicType();

    switch (basic)
    {
        case ::lldb::BasicType::eBasicTypeInvalid:
            {
                auto summary = object.GetSummary();
                if (summary && std::string(summary) == std::string("hxcppdbg"))
                {
                    auto pointer = *currentModel;

                    *currentModel = nullptr;

                    return hxcppdbg::core::model::ModelData(pointer);
                }
                else
                {
                    return hxcppdbg::core::model::ModelData_obj::MUnknown(String::create(type.GetName()));
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
                auto result = object.GetValueAsSigned();
                if (error.Fail())
                {
                    return hxcppdbg::core::model::ModelData_obj::MNull;
                }
                else
                {
                    return hxcppdbg::core::model::ModelData_obj::MInt(static_cast<int>(result));
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
                auto result = object.GetValueAsUnsigned();
                if (error.Fail())
                {
                    return hxcppdbg::core::model::ModelData_obj::MNull;
                }
                else
                {
                    return hxcppdbg::core::model::ModelData_obj::MInt(static_cast<int>(result));
                }
            }

        case ::lldb::BasicType::eBasicTypeBool:
            {
                auto error  = ::lldb::SBError();
                auto result = object.GetValueAsUnsigned();
                if (error.Fail())
                {
                    return hxcppdbg::core::model::ModelData_obj::MNull;
                }
                else
                {
                    return hxcppdbg::core::model::ModelData_obj::MBool(static_cast<bool>(result));
                }
            }

        case ::lldb::BasicType::eBasicTypeHalf:
        case ::lldb::BasicType::eBasicTypeFloat:
        case ::lldb::BasicType::eBasicTypeDouble:
            {
                auto error  = ::lldb::SBError();
                auto result = object.GetValueAsSigned();
                if (error.Fail())
                {
                    return hxcppdbg::core::model::ModelData_obj::MNull;
                }
                else
                {
                    return hxcppdbg::core::model::ModelData_obj::MFloat(static_cast<double>(result));
                }
            }

        default:
            return hxcppdbg::core::model::ModelData_obj::MUnknown(String::create(type.GetName()));
    }
}

hxcppdbg::core::sourcemap::GeneratedType hxcppdbg::core::drivers::lldb::native::models::findClassFor(std::string hxClassName)
{
    auto hxString  = String::create(hxClassName.c_str());
    auto callback  = Dynamic(*classLookup);
    auto foundType = hxcppdbg::core::sourcemap::GeneratedType(callback(hxString));

    return foundType;
}

hxcppdbg::core::sourcemap::GeneratedType hxcppdbg::core::drivers::lldb::native::models::findEnumFor(std::string hxEnumName)
{
    auto hxString  = String::create(hxEnumName.c_str());
    auto callback  = Dynamic(*enumLookup);
    auto foundType = hxcppdbg::core::sourcemap::GeneratedType(callback(hxString));

    return foundType;
}

bool hxcppdbg::core::drivers::lldb::native::models::setObjectPtrHxcppdbgModelData(::lldb::SBValue object, ::lldb::SBTypeSummaryOptions, ::lldb::SBStream& stream)
{
    auto mPtrMember = object.GetChildMemberWithName("mPtr");
    if (!mPtrMember.IsValid())
    {
        return false;
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