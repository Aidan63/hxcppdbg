#pragma once

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

#include "models/IDbgEngKeyable.hpp"

namespace hxcppdbg::core::drivers::dbgeng::native::models
{
    class LazyLocalStore : public IDbgEngKeyable<String>
    {
    private:
        Debugger::DataModel::ClientEx::Details::ObjectKeysRef<Debugger::DataModel::ClientEx::Object, Debugger::DataModel::ClientEx::Metadata> fields;

    public:
        LazyLocalStore(Debugger::DataModel::ClientEx::Details::ObjectKeysRef<Debugger::DataModel::ClientEx::Object, Debugger::DataModel::ClientEx::Metadata>);

        int count();
        hxcppdbg::core::drivers::dbgeng::native::NativeModelData at(const int);
        hxcppdbg::core::drivers::dbgeng::native::NativeModelData get(const String);
    };
}