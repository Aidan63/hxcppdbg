#include <hxcpp.h>
#include "NativeNamedModelData.hpp"

using namespace hxcppdbg::core::drivers::dbgeng::native;
using namespace Debugger::DataModel::ProviderEx;

TypedInstanceModel<NativeNamedModelData>* NativeNamedModelData_obj::factory = nullptr;

TypedInstanceModel<NativeNamedModelData>& NativeNamedModelData_obj::getFactory()
{
    if (factory == nullptr)
    {
        factory = new TypedInstanceModel<NativeNamedModelData>();
    }

    return *factory;
}

hxcppdbg::core::drivers::dbgeng::native::NativeNamedModelData_obj::NativeNamedModelData_obj(::String name, NativeModelData data)
    : name(name)
    , data(data)
{
}

void hxcppdbg::core::drivers::dbgeng::native::NativeNamedModelData_obj::__Mark(hx::MarkContext *__inCtx)
{
    HX_MARK_MEMBER(name);
    HX_MARK_MEMBER(data);
}

#ifdef HXCPP_VISIT_ALLOCS
void hxcppdbg::core::drivers::dbgeng::native::NativeNamedModelData_obj::__Visit(hx::VisitContext *__inCtx)
{
    HX_VISIT_MEMBER(name);
    HX_VISIT_MEMBER(data);
}
#endif