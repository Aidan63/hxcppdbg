#include <hxcpp.h>

#include "models/enums/ModelVariant.hpp"
#include "models/extensions/Utils.hpp"

#ifndef INCLUDED_hxcppdbg_core_model_ModelData
#include <hxcppdbg/core/model/ModelData.h>
#endif

#ifndef INCLUDED_hxcppdbg_core_model_Model
#include <hxcppdbg/core/model/Model.h>
#endif

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

hxcppdbg::core::model::ModelData hxcppdbg::core::drivers::dbgeng::native::models::enums::ModelVariant::getHxcppdbgModelData(const Debugger::DataModel::ClientEx::Object& object)
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
                        .KeyValue(L"HxcppdbgModelData")
                        .As<hxcppdbg::core::model::ModelData>();
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

                return hxcppdbg::core::model::ModelData_obj::MString(String::create(string.data(), string.size()));
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
                throw std::exception("unknown variant type");
            }
    }
}