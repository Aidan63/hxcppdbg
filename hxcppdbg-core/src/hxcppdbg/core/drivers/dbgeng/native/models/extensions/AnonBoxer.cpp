#include <hxcpp.h>

#include "AnonBoxer.hpp"

Debugger::DataModel::ProviderEx::TypedInstanceModel<hx::Anon>* hxcppdbg::core::drivers::dbgeng::native::models::extensions::AnonBoxer::factory = nullptr;

Debugger::DataModel::ProviderEx::TypedInstanceModel<hx::Anon>& hxcppdbg::core::drivers::dbgeng::native::models::extensions::AnonBoxer::getFactory()
{
    if (factory == nullptr)
    {
        factory = new Debugger::DataModel::ProviderEx::TypedInstanceModel<hx::Anon>();
    }

    return *factory;
}

Debugger::DataModel::ClientEx::Object hxcppdbg::core::drivers::dbgeng::native::models::extensions::AnonBoxer::Box(const hx::Anon& _object)
{
    return AnonBoxer::getFactory().CreateInstance(_object);
}

hx::Anon hxcppdbg::core::drivers::dbgeng::native::models::extensions::AnonBoxer::Unbox(const Debugger::DataModel::ClientEx::Object& _object)
{
    return AnonBoxer::getFactory().GetStoredInstance(_object);
}