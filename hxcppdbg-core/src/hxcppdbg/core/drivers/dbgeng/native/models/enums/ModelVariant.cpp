#include <hxcpp.h>

#include "models/enums/ModelVariant.hpp"
#include "models/extensions/Utils.hpp"

enum VariantType
{
    typeObject = 0,
    typeString,
    typeDouble,
    typeInt,
    typeInt64,
    typeBool,
};

hxcppdbg::core::drivers::dbgeng::native::models::enums::ModelVariant::ModelVariant()
    : hxcppdbg::core::drivers::dbgeng::native::models::extensions::HxcppdbgExtensionModel(std::wstring(L"cpp::Variant"))
{
    //
}

Debugger::DataModel::ClientEx::Object hxcppdbg::core::drivers::dbgeng::native::models::enums::ModelVariant::getHxcppdbgModelData(const Debugger::DataModel::ClientEx::Object& object)
{
    switch (object.FieldValue(L"type").As<int>())
    {
        case VariantType::typeObject:
            {
                return
                    object
                        .FieldValue(L"valObject")
                        .Dereference()
                        .GetValue()
                        .TryCastToRuntimeType()
                        .KeyValue(L"HxcppdbgModelData");
            }

        case VariantType::typeString:
            {
                auto strPointer = object.FieldValue(L"valStringPtr");
                auto strLength  = object.FieldValue(L"valStringLen").As<int>();
                auto string     = std::vector<char>(strLength);

                for (auto i = 0; i < strLength; i++)
                {
                    string[i] = strPointer.Dereference().As<char>();

                    strPointer++;
                }

                return hxcppdbg::core::drivers::dbgeng::native::NativeModelData_obj::HxString(String::create(string.data(), string.size()));
            }

        case VariantType::typeDouble:
            {
                return hxcppdbg::core::drivers::dbgeng::native::models::extensions::intrinsicObjectToHxcppdbgModelData(object.FieldValue(L"valDouble"));
            }

        case VariantType::typeInt:
            {
                return hxcppdbg::core::drivers::dbgeng::native::models::extensions::intrinsicObjectToHxcppdbgModelData(object.FieldValue(L"valInt"));
            }

        case VariantType::typeInt64:
            {
                return hxcppdbg::core::drivers::dbgeng::native::models::extensions::intrinsicObjectToHxcppdbgModelData(object.FieldValue(L"valInt64"));
            }

        case VariantType::typeBool:
            {
                return hxcppdbg::core::drivers::dbgeng::native::models::extensions::intrinsicObjectToHxcppdbgModelData(object.FieldValue(L"valBool"));
            }

        default:
            {
                throw std::runtime_error("unknown variant type");
            }
    }
}