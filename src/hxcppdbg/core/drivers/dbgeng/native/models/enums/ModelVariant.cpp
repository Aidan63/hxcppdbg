#include <hxcpp.h>

#include "models/enums/ModelVariant.hpp"

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
    : Debugger::DataModel::ProviderEx::ExtensionModel(Debugger::DataModel::ProviderEx::TypeSignatureRegistration(L"cpp::Variant"))
{
    AddStringDisplayableFunction(this, &hxcppdbg::core::drivers::dbgeng::native::models::enums::ModelVariant::getDisplayString);
}

std::wstring hxcppdbg::core::drivers::dbgeng::native::models::enums::ModelVariant::getDisplayString(const Debugger::DataModel::ClientEx::Object& object, const Debugger::DataModel::ClientEx::Metadata& metadata)
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
                        .TryToDisplayString()
                        .value_or(L"unable to read object");
            }

        case VariantType::typeString:
            {
                auto strPointer = object.FieldValue(L"valStringPtr");
                auto strLength  = object.FieldValue(L"valStringLen").As<int>();
                auto string     = std::wstring();

                for (auto i = 0; i < strLength; i++)
                {
                    auto c = strPointer.Dereference().As<char>();

                    string.push_back(c);

                    strPointer++;
                }

                return string;
            }

        case VariantType::typeDouble:
            {
                return std::to_wstring(object.FieldValue(L"valDouble").As<double>());
            }

        case VariantType::typeInt:
            {
                return std::to_wstring(object.FieldValue(L"valInt").As<int>());
            }

        case VariantType::typeInt64:
            {
                return std::to_wstring(object.FieldValue(L"valInt64").As<int64_t>());
            }

        case VariantType::typeBool:
            {
                return std::to_wstring(object.FieldValue(L"valBool").As<bool>());
            }

        default:
            {
                throw std::exception("unknown variant type");
            }
    }
}