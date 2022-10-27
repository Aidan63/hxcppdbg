#include <hxcpp.h>
#include "NativeModelData.hpp"
#include "models/LazyModels.hpp"

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
    return hx::CreateEnum<NativeModelData_obj>(HX_CSTRING("NNull"), 0, 0);
}

NativeModelData NativeModelData_obj::NInt(int i)
{
    return hx::CreateEnum<NativeModelData_obj>(HX_CSTRING("NInt"), 1, 1)->_hx_init(0, i);
}

NativeModelData NativeModelData_obj::NFloat(double f)
{
    return hx::CreateEnum<NativeModelData_obj>(HX_CSTRING("NFloat"), 2, 1)->_hx_init(0, f);
}

NativeModelData NativeModelData_obj::NBool(bool b)
{
    return hx::CreateEnum<NativeModelData_obj>(HX_CSTRING("NBool"), 3, 1)->_hx_init(0, b);
}

NativeModelData NativeModelData_obj::HxString(String s)
{
    return hx::CreateEnum<NativeModelData_obj>(HX_CSTRING("HxString"), 4, 1)->_hx_init(0, s);
}

NativeModelData NativeModelData_obj::HxArray(cpp::Pointer<hxcppdbg::core::drivers::dbgeng::native::models::LazyArray> a)
{
    return hx::CreateEnum<NativeModelData_obj>(HX_CSTRING("HxArray"), 5, 1)->_hx_init(0, a);
}

NativeModelData NativeModelData_obj::HxMap(cpp::Pointer<hxcppdbg::core::drivers::dbgeng::native::models::LazyMap> m)
{
    return hx::CreateEnum<NativeModelData_obj>(HX_CSTRING("HxMap"), 6, 1)->_hx_init(0, m);
}

bool NativeModelData_obj::__GetStatic(const String &_inName, Dynamic &_outValue, hx::PropertyAccess _propAccess)
{
    if (_inName == HX_CSTRING("NNull")) { _outValue = NativeModelData_obj::NNull_dyn(); return true; }
    if (_inName == HX_CSTRING("NInt")) { _outValue = NativeModelData_obj::NInt_dyn(); return true; }
    if (_inName == HX_CSTRING("NFloat")) { _outValue = NativeModelData_obj::NFloat_dyn(); return true; }
    if (_inName == HX_CSTRING("NBool")) { _outValue = NativeModelData_obj::NBool_dyn(); return true; }
    if (_inName == HX_CSTRING("HxString")) { _outValue = NativeModelData_obj::HxString_dyn(); return true; }
    if (_inName == HX_CSTRING("HxArray")) { _outValue = NativeModelData_obj::HxArray_dyn(); return true; }
    if (_inName == HX_CSTRING("HxMap")) { _outValue = NativeModelData_obj::HxMap_dyn(); return true; }
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
    if (_inName == HX_CSTRING("HxMap")) return NativeModelData_obj::HxMap_dyn();
    return hx::EnumBase_obj::__Field(_inName, _propAccess);
}

int NativeModelData_obj::__FindIndex(::String _inName)
{
    if (_inName == HX_CSTRING("NNull")) { return 0; }
    if (_inName == HX_CSTRING("NInt")) { return 1; }
    if (_inName == HX_CSTRING("NFloat")) { return 2; }
    if (_inName == HX_CSTRING("NBool")) { return 3; }
    if (_inName == HX_CSTRING("HxString")) { return 4; }
    if (_inName == HX_CSTRING("HxArray")) { return 5; }
    if (_inName == HX_CSTRING("HxMap")) { return 6; }
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
    if (_inName == HX_CSTRING("HxMap")) { return 1; }
    return hx::EnumBase_obj::__FindArgCount(_inName);
}

HX_DEFINE_CREATE_ENUM(NativeModelData_obj)

STATIC_HX_DEFINE_DYNAMIC_FUNC0(NativeModelData_obj, NNull, return)

STATIC_HX_DEFINE_DYNAMIC_FUNC1(NativeModelData_obj, NInt, return)

STATIC_HX_DEFINE_DYNAMIC_FUNC1(NativeModelData_obj, NFloat, return)

STATIC_HX_DEFINE_DYNAMIC_FUNC1(NativeModelData_obj, NBool, return)

STATIC_HX_DEFINE_DYNAMIC_FUNC1(NativeModelData_obj, HxString, return)

STATIC_HX_DEFINE_DYNAMIC_FUNC1(NativeModelData_obj, HxArray, return)

STATIC_HX_DEFINE_DYNAMIC_FUNC1(NativeModelData_obj, HxMap, return)

hx::Class NativeModelData_obj::__mClass;
