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

NativeModelData NativeModelData_obj::HxIntMap(cpp::Pointer<hxcppdbg::core::drivers::dbgeng::native::models::LazyMap> m)
{
    return hx::CreateEnum<NativeModelData_obj>(HX_CSTRING("HxIntMap"), Type::THxIntMap, 1)->_hx_init(0, m);
}

NativeModelData NativeModelData_obj::HxStringMap(cpp::Pointer<hxcppdbg::core::drivers::dbgeng::native::models::LazyMap> m)
{
    return hx::CreateEnum<NativeModelData_obj>(HX_CSTRING("HxStringMap"), Type::THxStringMap, 1)->_hx_init(0, m);
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
    if (_inName == HX_CSTRING("HxIntMap")) { _outValue = NativeModelData_obj::HxStringMap_dyn(); return true; }
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

hx::Class NativeModelData_obj::__mClass;
