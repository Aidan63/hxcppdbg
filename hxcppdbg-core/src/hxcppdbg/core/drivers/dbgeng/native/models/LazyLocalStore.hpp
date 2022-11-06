#pragma once

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

#include "models/IDbgEngKeyable.hpp"
#include "DbgModelClientEx.hpp"

namespace hxcppdbg::core::drivers::dbgeng::native::models
{
    class LazyLocalStore : public IDbgEngKeyable<String, Dynamic>
    {
    private:
        Debugger::DataModel::ClientEx::Details::ObjectKeysRef<Debugger::DataModel::ClientEx::Object, Debugger::DataModel::ClientEx::Metadata> fields;

    public:
        LazyLocalStore(Debugger::DataModel::ClientEx::Details::ObjectKeysRef<Debugger::DataModel::ClientEx::Object, Debugger::DataModel::ClientEx::Metadata>);

        int count();
        Dynamic at(const int);
        hxcppdbg::core::drivers::dbgeng::native::NativeModelData get(const String);
    };
}