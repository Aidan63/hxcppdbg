#pragma once

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

#include "models/LazyMap.hpp"
#include "models/LazyArray.hpp"
#include "models/LazyAnonFields.hpp"
#include "models/LazyClassFields.hpp"
#include "models/LazyEnumArguments.hpp"
#include "models/LazyNativeArray.hpp"
#include "models/LazyNativeType.hpp"

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
            THxDynamicMap,
            THxEnum,
            THxAnon,
            THxClass,
            TPointer,
            TArray,
            TType
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
        static NativeModelData HxIntMap(cpp::Pointer<models::LazyIntMap>);
        static Dynamic HxIntMap_dyn();
        static NativeModelData HxStringMap(cpp::Pointer<models::LazyStringMap>);
        static Dynamic HxStringMap_dyn();
        static NativeModelData HxDynamicMap(cpp::Pointer<models::LazyDynamicMap>);
        static Dynamic HxDynamicMap_dyn();
        static NativeModelData HxEnum(Dynamic, String, cpp::Pointer<models::LazyEnumArguments>);
        static Dynamic HxEnum_dyn();
        static NativeModelData HxAnon(cpp::Pointer<models::LazyAnonFields>);
        static Dynamic HxAnon_dyn();
        static NativeModelData HxClass(Dynamic, cpp::Pointer<models::LazyClassFields>);
        static Dynamic HxClass_dyn();

        static NativeModelData NPointer(uint64_t, NativeModelData);
        static Dynamic NPointer_dyn();
        static NativeModelData NArray(String, cpp::Pointer<models::LazyNativeArray>);
        static Dynamic NArray_dyn();
        static NativeModelData NType(String, cpp::Pointer<models::LazyNativeType>);
        static Dynamic NType_dyn();
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