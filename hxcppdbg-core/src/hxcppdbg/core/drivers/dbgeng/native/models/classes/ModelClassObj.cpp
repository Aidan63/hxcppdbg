#include <hxcpp.h>

#include "models/classes/ModelClassObj.hpp"
#include "models/extensions/Utils.hpp"
#include "models/LazyClassFields.hpp"

#ifndef INCLUDED_hxcppdbg_core_sourcemap_GeneratedType
#include <hxcppdbg/core/sourcemap/GeneratedType.h>
#endif

hxcppdbg::core::drivers::dbgeng::native::models::classes::ModelClassObj::ModelClassObj(hxcppdbg::core::sourcemap::GeneratedType _type)
    : type(_type), hxcppdbg::core::drivers::dbgeng::native::models::extensions::HxcppdbgExtensionModel(_type->cpp.wc_str())
{
    AddMethod(L"Count", this, &ModelClassObj::count);
    AddMethod(L"At", this, &ModelClassObj::at);
    AddMethod(L"Get", this, &ModelClassObj::get);
}

Debugger::DataModel::ClientEx::Object hxcppdbg::core::drivers::dbgeng::native::models::classes::ModelClassObj::getHxcppdbgModelData(const Debugger::DataModel::ClientEx::Object& _object)
{
    return hxcppdbg::core::drivers::dbgeng::native::NativeModelData_obj::HxClass(type, new hxcppdbg::core::drivers::dbgeng::native::models::LazyClassFields(_object));
}

Debugger::DataModel::ClientEx::Object hxcppdbg::core::drivers::dbgeng::native::models::classes::ModelClassObj::count(const Debugger::DataModel::ClientEx::Object& _object)
{
    auto count = 0;
    for (auto&& field : _object.Fields())
    {
        count++;
    }

    return count;
}

Debugger::DataModel::ClientEx::Object hxcppdbg::core::drivers::dbgeng::native::models::classes::ModelClassObj::at(const Debugger::DataModel::ClientEx::Object& _object, const int _index)
{
    auto count = 0;
    for (auto&& field : _object.Fields())
    {
        if (count == _index)
        {
            auto object = std::get<1>(field).GetValue();

            return
                object.Type().IsIntrinsic()
                    ? hxcppdbg::core::drivers::dbgeng::native::models::extensions::intrinsicObjectToHxcppdbgModelData(object)
                    : object.KeyValue(L"HxcppdbgModelData");
        }

        count++;
    }

    throw std::runtime_error("Failed to find field");
}

Debugger::DataModel::ClientEx::Object hxcppdbg::core::drivers::dbgeng::native::models::classes::ModelClassObj::get(const Debugger::DataModel::ClientEx::Object& _object, const std::wstring _field)
{
    auto value = _object.FieldValue(_field);

    return
        value.Type().IsIntrinsic()
            ? hxcppdbg::core::drivers::dbgeng::native::models::extensions::intrinsicObjectToHxcppdbgModelData(value)
            : value.KeyValue(L"HxcppdbgModelData");
}