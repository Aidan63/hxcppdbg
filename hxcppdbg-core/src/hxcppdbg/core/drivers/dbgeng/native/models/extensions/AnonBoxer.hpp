#pragma once

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

#include "DbgModelClientEx.hpp"

namespace hxcppdbg::core::drivers::dbgeng::native::models::extensions
{
    struct AnonBoxer : public Debugger::DataModel::ClientEx::Boxing::BoxObject<hx::Anon>
    {
    private:
        static Debugger::DataModel::ProviderEx::TypedInstanceModel<hx::Anon>* factory;

        static Debugger::DataModel::ProviderEx::TypedInstanceModel<hx::Anon>& getFactory();

    public:
        static Debugger::DataModel::ClientEx::Object Box(const hx::Anon& _object)
        {
            return AnonBoxer::getFactory().CreateInstance(_object);
        }

        static hx::Anon Unbox(const Debugger::DataModel::ClientEx::Object& _object)
        {
            return AnonBoxer::getFactory().GetStoredInstance(_object);
        }
    };
}