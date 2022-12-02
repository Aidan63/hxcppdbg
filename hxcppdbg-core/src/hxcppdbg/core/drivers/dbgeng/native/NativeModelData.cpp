#include <hxcpp.h>
#include "NativeModelData.hpp"

using namespace hxcppdbg::core::drivers::dbgeng::native;
using namespace Debugger::DataModel::ProviderEx;

TypedInstanceModel<NativeModelData>* NativeModelData_obj::factory = nullptr;

TypedInstanceModel<NativeModelData>& NativeModelData_obj::getFactory()
{
    if (factory == nullptr)
    {
        factory = new TypedInstanceModel<NativeModelData>();
    }

    return *factory;
}

NativeModelData NativeModelData_obj::NNull()
{
    return hx::CreateEnum<NativeModelData_obj>(HX_CSTRING("NNull"), Type::TNull, 0);
}

NativeModelData NativeModelData_obj::NInt(int i)
{
    return hx::CreateEnum<NativeModelData_obj>(HX_CSTRING("NInt"), Type::TInt, 1)->_hx_init(0, i);
}

NativeModelData NativeModelData_obj::NFloat(double f)
{
    return hx::CreateEnum<NativeModelData_obj>(HX_CSTRING("NFloat"), Type::TFloat, 1)->_hx_init(0, f);
}

NativeModelData NativeModelData_obj::NBool(bool b)
{
    return hx::CreateEnum<NativeModelData_obj>(HX_CSTRING("NBool"), Type::TBool, 1)->_hx_init(0, b);
}

NativeModelData NativeModelData_obj::HxString(String s)
{
    return hx::CreateEnum<NativeModelData_obj>(HX_CSTRING("HxString"), Type::THxString, 1)->_hx_init(0, s);
}

NativeModelData NativeModelData_obj::HxArray(cpp::Pointer<hxcppdbg::core::drivers::dbgeng::native::models::LazyArray> a)
{
    return hx::CreateEnum<NativeModelData_obj>(HX_CSTRING("HxArray"), Type::THxArray, 1)->_hx_init(0, a);
}

NativeModelData NativeModelData_obj::HxIntMap(cpp::Pointer<hxcppdbg::core::drivers::dbgeng::native::models::LazyIntMap> m)
{
    return hx::CreateEnum<NativeModelData_obj>(HX_CSTRING("HxIntMap"), Type::THxIntMap, 1)->_hx_init(0, m);
}

NativeModelData NativeModelData_obj::HxStringMap(cpp::Pointer<hxcppdbg::core::drivers::dbgeng::native::models::LazyStringMap> m)
{
    return hx::CreateEnum<NativeModelData_obj>(HX_CSTRING("HxStringMap"), Type::THxStringMap, 1)->_hx_init(0, m);
}

NativeModelData NativeModelData_obj::HxDynamicMap(cpp::Pointer<hxcppdbg::core::drivers::dbgeng::native::models::LazyDynamicMap> m)
{
    return hx::CreateEnum<NativeModelData_obj>(HX_CSTRING("HxDynamicMap"), Type::THxDynamicMap, 1)->_hx_init(0, m);
}

NativeModelData NativeModelData_obj::HxEnum(Dynamic _type, String _tag, cpp::Pointer<hxcppdbg::core::drivers::dbgeng::native::models::LazyEnumArguments> _args)
{
    return hx::CreateEnum<NativeModelData_obj>(HX_CSTRING("HxEnum"), Type::THxEnum, 3)->_hx_init(0, _type)->_hx_init(1, _tag)->_hx_init(2, _args);
}

NativeModelData NativeModelData_obj::HxAnon(cpp::Pointer<hxcppdbg::core::drivers::dbgeng::native::models::LazyAnonFields> f)
{
    return hx::CreateEnum<NativeModelData_obj>(HX_CSTRING("HxEnum"), Type::THxAnon, 1)->_hx_init(0, f);
}

NativeModelData NativeModelData_obj::HxClass(Dynamic _type, cpp::Pointer<hxcppdbg::core::drivers::dbgeng::native::models::LazyClassFields> _fields)
{
    return hx::CreateEnum<NativeModelData_obj>(HX_CSTRING("HxClass"), Type::THxClass, 2)->_hx_init(0, _type)->_hx_init(1, _fields);
}

NativeModelData NativeModelData_obj::NPointer(uint64_t _address, NativeModelData _dereferenced)
{
    return hx::CreateEnum<NativeModelData_obj>(HX_CSTRING("NPointer"), Type::TPointer, 2)->_hx_init(0, _address)->_hx_init(1, _dereferenced);
}

bool NativeModelData_obj::__GetStatic(const String &_inName, Dynamic &_outValue, hx::PropertyAccess _propAccess)
{
    if (_inName == HX_CSTRING("NNull")) { _outValue = NativeModelData_obj::NNull_dyn(); return true; }
    if (_inName == HX_CSTRING("NInt")) { _outValue = NativeModelData_obj::NInt_dyn(); return true; }
    if (_inName == HX_CSTRING("NFloat")) { _outValue = NativeModelData_obj::NFloat_dyn(); return true; }
    if (_inName == HX_CSTRING("NBool")) { _outValue = NativeModelData_obj::NBool_dyn(); return true; }
    if (_inName == HX_CSTRING("HxString")) { _outValue = NativeModelData_obj::HxString_dyn(); return true; }
    if (_inName == HX_CSTRING("HxArray")) { _outValue = NativeModelData_obj::HxArray_dyn(); return true; }
    if (_inName == HX_CSTRING("HxIntMap")) { _outValue = NativeModelData_obj::HxIntMap_dyn(); return true; }
    if (_inName == HX_CSTRING("HxStringMap")) { _outValue = NativeModelData_obj::HxStringMap_dyn(); return true; }
    if (_inName == HX_CSTRING("HxDynamicMap")) { _outValue = NativeModelData_obj::HxDynamicMap_dyn(); return true; }
    if (_inName == HX_CSTRING("HxEnum")) { _outValue = NativeModelData_obj::HxEnum_dyn(); return true; }
    if (_inName == HX_CSTRING("HxAnon")) { _outValue = NativeModelData_obj::HxAnon_dyn(); return true; }
    if (_inName == HX_CSTRING("HxClass")) { _outValue = NativeModelData_obj::HxClass_dyn(); return true; }
    if (_inName == HX_CSTRING("NPointer")) { _outValue = NativeModelData_obj::NPointer_dyn(); return true; }
    return hx::EnumBase_obj::__GetStatic(_inName, _outValue, _propAccess);
}

hx::Val NativeModelData_obj::__Field(const String &_inName, hx::PropertyAccess _propAccess)
{
    if (_inName == HX_CSTRING("NNull")) return NativeModelData_obj::NNull_dyn();
    if (_inName == HX_CSTRING("NInt")) return NativeModelData_obj::NInt_dyn();
    if (_inName == HX_CSTRING("NFloat")) return NativeModelData_obj::NFloat_dyn();
    if (_inName == HX_CSTRING("NBool")) return NativeModelData_obj::NBool_dyn();
    if (_inName == HX_CSTRING("HxString")) return NativeModelData_obj::HxString_dyn();
    if (_inName == HX_CSTRING("HxArray")) return NativeModelData_obj::HxArray_dyn();
    if (_inName == HX_CSTRING("HxIntMap")) return NativeModelData_obj::HxIntMap_dyn();
    if (_inName == HX_CSTRING("HxStringMap")) return NativeModelData_obj::HxStringMap_dyn();
    if (_inName == HX_CSTRING("HxDynamicMap")) return NativeModelData_obj::HxDynamicMap_dyn();
    if (_inName == HX_CSTRING("HxEnum")) return NativeModelData_obj::HxEnum_dyn();
    if (_inName == HX_CSTRING("HxAnon")) return NativeModelData_obj::HxAnon_dyn();
    if (_inName == HX_CSTRING("HxClass")) return NativeModelData_obj::HxClass_dyn();
    if (_inName == HX_CSTRING("NPointer")) return NativeModelData_obj::NPointer_dyn();
    return hx::EnumBase_obj::__Field(_inName, _propAccess);
}

int NativeModelData_obj::__FindIndex(::String _inName)
{
    if (_inName == HX_CSTRING("NNull")) { return Type::TNull; }
    if (_inName == HX_CSTRING("NInt")) { return Type::TInt; }
    if (_inName == HX_CSTRING("NFloat")) { return Type::TFloat; }
    if (_inName == HX_CSTRING("NBool")) { return Type::TBool; }
    if (_inName == HX_CSTRING("HxString")) { return Type::THxString; }
    if (_inName == HX_CSTRING("HxArray")) { return Type::THxArray; }
    if (_inName == HX_CSTRING("HxIntMap")) { return Type::THxIntMap; }
    if (_inName == HX_CSTRING("HxStringMap")) { return Type::THxStringMap; }
    if (_inName == HX_CSTRING("HxDynamicMap")) { return Type::THxDynamicMap; }
    if (_inName == HX_CSTRING("HxEnum")) { return Type::THxEnum; }
    if (_inName == HX_CSTRING("HxAnon")) { return Type::THxAnon; }
    if (_inName == HX_CSTRING("HxClass")) { return Type::THxClass; }
    if (_inName == HX_CSTRING("NPointer")) { return Type::TPointer; }
    return hx::EnumBase_obj::__FindIndex(_inName);
}

int NativeModelData_obj::__FindArgCount(::String _inName)
{
    if (_inName == HX_CSTRING("NNull")) { return 0; }
    if (_inName == HX_CSTRING("NInt")) { return 1; }
    if (_inName == HX_CSTRING("NFloat")) { return 1; }
    if (_inName == HX_CSTRING("NBool")) { return 1; }
    if (_inName == HX_CSTRING("HxString")) { return 1; }
    if (_inName == HX_CSTRING("HxArray")) { return 1; }
    if (_inName == HX_CSTRING("HxIntMap")) { return 1; }
    if (_inName == HX_CSTRING("HxStringMap")) { return 1; }
    if (_inName == HX_CSTRING("HxDynamicMap")) { return 1; }
    if (_inName == HX_CSTRING("HxEnum")) { return 3; }
    if (_inName == HX_CSTRING("HxAnon")) { return 1; }
    if (_inName == HX_CSTRING("HxClass")) { return 2; }
    if (_inName == HX_CSTRING("NPointer")) { return 2; }
    return hx::EnumBase_obj::__FindArgCount(_inName);
}

HX_DEFINE_CREATE_ENUM(NativeModelData_obj)

STATIC_HX_DEFINE_DYNAMIC_FUNC0(NativeModelData_obj, NNull, return)

STATIC_HX_DEFINE_DYNAMIC_FUNC1(NativeModelData_obj, NInt, return)

STATIC_HX_DEFINE_DYNAMIC_FUNC1(NativeModelData_obj, NFloat, return)

STATIC_HX_DEFINE_DYNAMIC_FUNC1(NativeModelData_obj, NBool, return)

STATIC_HX_DEFINE_DYNAMIC_FUNC1(NativeModelData_obj, HxString, return)

STATIC_HX_DEFINE_DYNAMIC_FUNC1(NativeModelData_obj, HxArray, return)

STATIC_HX_DEFINE_DYNAMIC_FUNC1(NativeModelData_obj, HxIntMap, return)

STATIC_HX_DEFINE_DYNAMIC_FUNC1(NativeModelData_obj, HxStringMap, return)

STATIC_HX_DEFINE_DYNAMIC_FUNC1(NativeModelData_obj, HxDynamicMap, return)

STATIC_HX_DEFINE_DYNAMIC_FUNC3(NativeModelData_obj, HxEnum, return)

STATIC_HX_DEFINE_DYNAMIC_FUNC1(NativeModelData_obj, HxAnon, return)

STATIC_HX_DEFINE_DYNAMIC_FUNC2(NativeModelData_obj, HxClass, return)

STATIC_HX_DEFINE_DYNAMIC_FUNC2(NativeModelData_obj, NPointer, return)

hx::Class NativeModelData_obj::__mClass;
