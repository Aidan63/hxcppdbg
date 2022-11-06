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