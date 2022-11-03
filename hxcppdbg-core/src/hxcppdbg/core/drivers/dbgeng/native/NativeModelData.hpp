#pragma once

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

#include "models/LazyMap.hpp"
#include "models/LazyArray.hpp"
#include "models/LazyAnonFields.hpp"
#include "models/LazyClassFields.hpp"
#include "models/LazyEnumArguments.hpp"

HX_DECLARE_CLASS3(hxcppdbg, core, sourcemap, GeneratedType)

namespace hxcppdbg::core::drivers::dbgeng::native
{
    class NativeModelData_obj : public hx::EnumBase_obj
    {
        typedef NativeModelData_obj OBJ_;

    private:
        static Debugger::DataModel::ProviderEx::TypedInstanceModel<NativeModelData>* factory;

    public:
        enum Type
        {
            TNull,
            TInt,
            TFloat,
            TBool,
            THxString,
            THxArray,
            THxIntMap,
            THxStringMap,
            THxEnum,
            THxAnon,
            THxClass
        };

        NativeModelData_obj() = default;

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
        static NativeModelData HxArray(cpp::Pointer<models::LazyArray>);
        static Dynamic HxArray_dyn();
        static NativeModelData HxIntMap(cpp::Pointer<models::LazyMap<int>>);
        static Dynamic HxIntMap_dyn();
        static NativeModelData HxStringMap(cpp::Pointer<models::LazyMap<String>>);
        static Dynamic HxStringMap_dyn();
        static NativeModelData HxEnum(hxcppdbg::core::sourcemap::GeneratedType, String, cpp::Pointer<models::LazyEnumArguments>);
        static Dynamic HxEnum_dyn();
        static NativeModelData HxAnon(cpp::Pointer<models::LazyAnonFields>);
        static Dynamic HxAnon_dyn();
        static NativeModelData HxClass(hxcppdbg::core::sourcemap::GeneratedType, cpp::Pointer<models::LazyClassFields>);
        static Dynamic HxClass_dyn();
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