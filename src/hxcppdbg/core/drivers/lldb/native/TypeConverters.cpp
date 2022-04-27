#include <hxcpp.h>

#include "TypeConverters.hpp"
#include <exception>
#include <SBError.h>
#include <SBTypeSummary.h>
#include <SBTypeCategory.h>
#include <SBExpressionOptions.h>
#include <SBAddress.h>

#ifndef INCLUDED_hxcppdbg_core_model_Model
#include <hxcppdbg/core/model/Model.h>
#endif

#ifndef INCLUDED_hxcppdbg_core_model_ModelData
#include <hxcppdbg/core/model/ModelData.h>
#endif

hxcppdbg::core::model::ModelData hxcppdbg::core::drivers::lldb::native::TypeConverters::valueAsString(::lldb::SBValue value)
{
    auto lengthValue = value.GetChildMemberWithName("length");
    if (!lengthValue.IsValid())
    {
        throw std::runtime_error(lengthValue.GetError().GetCString());
    }

    auto stringExpr = value.EvaluateExpression("__CStr()");
    if (!stringExpr.IsValid())
    {
        throw std::runtime_error(stringExpr.GetError().GetCString());
    }

    auto length     = lengthValue.GetValueAsSigned();
    auto stringData = stringExpr.GetPointeeData(0, length);
    auto error      = ::lldb::SBError();
    auto buffer     = std::vector<char>(length);
    auto string     = stringData.ReadRawData(error, 0, buffer.data(), length);
    if (error.Fail())
    {
        throw std::runtime_error(error.GetCString());
    }
    
    return hxcppdbg::core::model::ModelData_obj::MString(String::create(buffer.data(), length));
}

hxcppdbg::core::model::ModelData hxcppdbg::core::drivers::lldb::native::TypeConverters::valueAsDynamic(::lldb::SBValue value)
{
    auto ptrValue = value.GetChildMemberWithName("mPtr");
    if (!ptrValue.IsValid())
    {
        throw std::runtime_error(ptrValue.GetError().GetCString());
    }

    auto address = ptrValue.GetAddress();
    if (!address.IsValid())
    {
        throw std::runtime_error("Invalid address");
    }

    if (address.GetOffset() == NULL)
    {
        return hxcppdbg::core::model::ModelData_obj::MNull;
    }
    else
    {
        return convertValue(ptrValue.Dereference());
    }
}

hxcppdbg::core::model::ModelData hxcppdbg::core::drivers::lldb::native::TypeConverters::convertValue(::lldb::SBValue value)
{
    auto type  = value.GetType();
    auto basic = type.GetBasicType();

    switch (basic)
    {
        case ::lldb::BasicType::eBasicTypeInvalid:
            {
                auto name = std::string(type.GetName());

                // Type is not a basic type, so we must look closer at it...
                if (name == std::string("String"))
                {
                    return valueAsString(value);
                }

                if (name == std::string("hx::StringData"))
                {
                    return valueAsString(value.GetChildMemberWithName("mValue"));
                }

                if (name == std::string("Dynamic"))
                {
                    return valueAsString(value);
                }

                // If its a class see if it descends from hx::Enum_obj, if so read the object as an enum.

                // If it is not an enum but still inherits from hx::Object then read it as a class.
                
                
                return hxcppdbg::core::model::ModelData_obj::MUnknown(String::create(name.c_str()));
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
                auto result = value.GetValueAsSigned();
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
                auto result = value.GetValueAsUnsigned();
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
                auto result = value.GetValueAsUnsigned();
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
                auto result = value.GetValueAsSigned();
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