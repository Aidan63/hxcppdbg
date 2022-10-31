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
    AddMethod(L"Field", this, &ModelClassObj::field);
}

Debugger::DataModel::ClientEx::Object hxcppdbg::core::drivers::dbgeng::native::models::classes::ModelClassObj::getHxcppdbgModelData(const Debugger::DataModel::ClientEx::Object& _object)
{
    return
        hxcppdbg::core::drivers::dbgeng::native::NativeModelData_obj::HxClass(type, new hxcppdbg::core::drivers::dbgeng::native::models::LazyClassFields(_object));
}

Debugger::DataModel::ClientEx::Object hxcppdbg::core::drivers::dbgeng::native::models::classes::ModelClassObj::count(const Debugger::DataModel::ClientEx::Object& _object)
{
    return 0;
}

Debugger::DataModel::ClientEx::Object hxcppdbg::core::drivers::dbgeng::native::models::classes::ModelClassObj::field(const Debugger::DataModel::ClientEx::Object& _object, std::wstring _field)
{
    try
    {
        auto value = _object.FieldValue(_field);

        return
            value.Type().IsIntrinsic()
                ? hxcppdbg::core::drivers::dbgeng::native::models::extensions::intrinsicObjectToHxcppdbgModelData(value)
                : value.KeyValue(L"HxcppdbgModelData");
    }
    catch (const std::exception& exn)
    {
        return NativeModelData_obj::NNull();
    }
}