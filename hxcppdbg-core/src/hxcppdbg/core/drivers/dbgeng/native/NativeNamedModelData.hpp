#pragma once

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

#include "NativeModelData.hpp"

namespace hxcppdbg::core::drivers::dbgeng::native
{
    class NativeNamedModelData_obj final : public hx::Object
    {
    private:
        static Debugger::DataModel::ProviderEx::TypedInstanceModel<NativeNamedModelData>* factory;

    public:
        static Debugger::DataModel::ProviderEx::TypedInstanceModel<NativeNamedModelData>& getFactory();

        NativeNamedModelData_obj(::String name, NativeModelData data);

        ::String name;
        NativeModelData data;

        virtual void __Mark(hx::MarkContext *__inCtx) override final;
#ifdef HXCPP_VISIT_ALLOCS
        virtual void __Visit(hx::VisitContext *__inCtx) override final;
#endif
    };
}

namespace Debugger::DataModel::ClientEx::Boxing
{
    template<>
    struct BoxObject<hxcppdbg::core::drivers::dbgeng::native::NativeNamedModelData>
    {
        static Object Box(const hxcppdbg::core::drivers::dbgeng::native::NativeNamedModelData& model)
        {
            return hxcppdbg::core::drivers::dbgeng::native::NativeNamedModelData_obj::getFactory().CreateInstance(model);
        }

        static hxcppdbg::core::drivers::dbgeng::native::NativeNamedModelData Unbox(const Object& object)
        {
            return hxcppdbg::core::drivers::dbgeng::native::NativeNamedModelData_obj::getFactory().GetStoredInstance(object);
        }
    };
}