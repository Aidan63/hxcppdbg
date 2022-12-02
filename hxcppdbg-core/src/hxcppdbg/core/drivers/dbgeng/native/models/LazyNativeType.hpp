#pragma once

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

#include "models/IDbgEngKeyable.hpp"

namespace hxcppdbg::core::drivers::dbgeng::native::models
{
    class LazyNativeType : public IDbgEngKeyable<String, Dynamic>
    {
    private:
        std::optional<int> size;
        std::optional<Debugger::DataModel::ClientEx::Details::ObjectKeysRef<Debugger::DataModel::ClientEx::Object, Debugger::DataModel::ClientEx::Metadata>> fields;

    public:
        LazyNativeType(const Debugger::DataModel::ClientEx::Object&);

        int count();
        Dynamic at(const int);
        hxcppdbg::core::drivers::dbgeng::native::NativeModelData get(const String);
    };
}