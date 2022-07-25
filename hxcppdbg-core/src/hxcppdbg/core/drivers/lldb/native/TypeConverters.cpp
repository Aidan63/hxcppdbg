#include <hxcpp.h>

#include "TypeConverters.hpp"
#include <exception>
#include <SBError.h>
#include <SBTypeSummary.h>
#include <SBTypeCategory.h>
#include <SBExpressionOptions.h>
#include <SBAddress.h>
#include "fmt/format.h"

#ifndef INCLUDED_hxcppdbg_core_model_Model
#include <hxcppdbg/core/model/Model.h>
#endif

#ifndef INCLUDED_hxcppdbg_core_model_ModelData
#include <hxcppdbg/core/model/ModelData.h>
#endif

String hxcppdbg::core::drivers::lldb::native::TypeConverters::readString(::lldb::SBValue value)
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

    return String::create(buffer.data(), length);
}

hxcppdbg::core::model::ModelData hxcppdbg::core::drivers::lldb::native::TypeConverters::valueAsString(::lldb::SBValue value)
{  
    return hxcppdbg::core::model::ModelData_obj::MString(readString(value));
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

    if (address.GetOffset() == uint64_t{ 0 })
    {
        return hxcppdbg::core::model::ModelData_obj::MNull;
    }
    else
    {
        return convertValue(ptrValue.Dereference());
    }
}

hxcppdbg::core::model::ModelData hxcppdbg::core::drivers::lldb::native::TypeConverters::valueAsArray(::lldb::SBValue value)
{
    auto lengthValue = value.GetChildMemberWithName("length");
    if (!lengthValue.IsValid())
    {
        throw std::runtime_error(lengthValue.GetError().GetCString());
    }

    auto element     = value.GetType().GetTemplateArgumentType(0);
    auto elementName = element.GetName();
    auto elementSize = element.GetByteSize();

    auto length = lengthValue.GetValueAsSigned();
    auto output = Array<hxcppdbg::core::model::ModelData>(length, length);

    for (auto i = 0; i < length; i++)
    {
        auto expr      = fmt::format("({0}*)(mBase + {1})", elementName, i * elementSize);
        auto evaluated = value.EvaluateExpression(expr.c_str());

        output[i] = convertValue(evaluated.Dereference());
    }

    return hxcppdbg::core::model::ModelData_obj::MArray(output);
}

hxcppdbg::core::model::ModelData hxcppdbg::core::drivers::lldb::native::TypeConverters::valueAsVariant(::lldb::SBValue value)
{
    enum VariantType
    {
        typeObject = 0,
        typeString,
        typeDouble,
        typeInt,
        typeInt64,
        typeBool,
    };

    auto type = (VariantType)(value.GetChildMemberWithName("type").GetValueAsSigned());

    switch (type)
    {
        case VariantType::typeObject:
            {
                return convertValue(value.GetChildMemberWithName("valObject").Dereference());
            }

        case VariantType::typeString:
            {
                auto strPointer = value.GetChildMemberWithName("valStringPtr");
                auto strLength  = value.GetChildMemberWithName("valStringLen").GetValueAsSigned();
                auto string     = std::vector<char>(strLength);

                auto error = ::lldb::SBError();
                strPointer.GetPointeeData().ReadRawData(error, 0, string.data(), strLength);

                return hxcppdbg::core::model::ModelData_obj::MString(String::create(string.data(), string.size()));
            }

        case VariantType::typeDouble:
            {
                return convertValue(value.GetChildMemberWithName("valDouble"));
            }

        case VariantType::typeInt:
            {
                return convertValue(value.GetChildMemberWithName("valInt"));
            }

        case VariantType::typeInt64:
            {
                return convertValue(value.GetChildMemberWithName("valInt64"));
            }

        case VariantType::typeBool:
            {
                return convertValue(value.GetChildMemberWithName("valBool"));
            }

        default:
            {
                throw std::runtime_error("unknown variant type");
            }
    }
}

hxcppdbg::core::model::ModelData hxcppdbg::core::drivers::lldb::native::TypeConverters::valueAsEnum(::lldb::SBValue value)
{
    auto tag        = readString(value.GetChildMemberWithName("_hx_tag"));
    auto fieldCount = value.GetChildMemberWithName("mFixedFields").GetValueAsSigned();
    auto fields     = Array<Dynamic>(fieldCount, fieldCount);

    if (fieldCount == 0)
    {
        return hxcppdbg::core::model::ModelData_obj::MEnum(null(), tag, fields);
    }

    auto variants = value.EvaluateExpression("(cpp::Variant*)(this + 1)");
    for (auto i = 0; i < fieldCount; i++)
    {
        fields[i] = convertValue(value.EvaluateExpression(fmt::format("(cpp::Variant*)(this + {0})", i + 1).c_str()));
    }

    return hxcppdbg::core::model::ModelData_obj::MEnum(null(), tag, fields);
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

                if (name == std::string("Dynamic"))
                {
                    return valueAsString(value);
                }

                if (name == std::string("hx::StringData") ||
                    name == std::string("hx::IntData") ||
                    name == std::string("hx::BoolData") ||
                    name == std::string("hx::DoubleData") ||
                    name == std::string("hx::Int64Data") ||
                    name == std::string("hx::PointerData"))
                {
                    return valueAsString(value.GetChildMemberWithName("mValue"));
                }

                if (name == std::string("cpp::Variant"))
                {
                    return valueAsVariant(value);
                }

                if (name.rfind("Array_obj<", 0) == 0)
                {
                    return valueAsArray(value);
                }

                for (auto i = 0; i < type.GetNumberOfDirectBaseClasses(); i++)
                {
                    auto ancestor     = type.GetDirectBaseClassAtIndex(i);
                    auto ancestorType = std::string(ancestor.GetName());

                    if (ancestorType.rfind("hx::ObjectPtr<", 0) == 0)
                    {
                        return convertValue(value.GetChildMemberWithName("mPtr").Dereference());
                    }
                    if (ancestorType == std::string("hx::EnumBase_obj"))
                    {
                        return valueAsEnum(value.GetChildMemberWithName("mPtr").Dereference());
                    }
                    if (ancestorType == std::string("hx::Object"))
                    {
                        //
                    }
                }
                
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