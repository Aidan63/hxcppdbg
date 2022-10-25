#pragma once

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

#include "DbgModelClientEx.hpp"

HX_DECLARE_CLASS5(hxcppdbg, core, drivers, dbgeng, native, NativeModelData)

namespace hxcppdbg::core::drivers::dbgeng::native
{
    class NativeModelData_obj : public hx::EnumBase_obj
    {
        typedef NativeModelData_obj OBJ_;

    private:
        static Debugger::DataModel::ProviderEx::TypedInstanceModel<NativeModelData>* factory;

    public:
        NativeModelData_obj() {};

        HX_DO_ENUM_RTTI;

        static Debugger::DataModel::ProviderEx::TypedInstanceModel<NativeModelData>& getFactory();
        static bool __GetStatic(const String&, Dynamic&, hx::PropertyAccess);

        String GetEnumName() const { return HX_CSTRING("hxcppdbg.core.drivers.dbgeng.native.NativeModelData"); }
        String __ToString() const { return HX_CSTRING("NativeModelData.") + _hx_tag; }

        static NativeModelData NNull();
        static Dynamic NNull_dyn();
        static NativeModelData NInt(int);
        static Dynamic NInt_dyn();
        static NativeModelData NFloat(double);
        static Dynamic NFloat_dyn();
        static NativeModelData NBool(bool);
        static Dynamic NBool_dyn();

        static NativeModelData HxString(String);
        static Dynamic HxString_dyn();
        static NativeModelData HxArray(Dynamic);
        static Dynamic HxArray_dyn();
        static NativeModelData HxMap(Dynamic);
        static Dynamic HxMap_dyn();
    };
}

namespace Debugger::DataModel::ClientEx::Boxing
{
    template<>
    struct BoxObject<hxcppdbg::core::drivers::dbgeng::native::NativeModelData>
    {
        static Object Box(const hxcppdbg::core::drivers::dbgeng::native::NativeModelData& model)
        {
            return hxcppdbg::core::drivers::dbgeng::native::NativeModelData_obj::getFactory().CreateInstance(model);
        }

        static hxcppdbg::core::drivers::dbgeng::native::NativeModelData Unbox(const Object& object)
        {
            return hxcppdbg::core::drivers::dbgeng::native::NativeModelData_obj::getFactory().GetStoredInstance(object);
        }
    };
}