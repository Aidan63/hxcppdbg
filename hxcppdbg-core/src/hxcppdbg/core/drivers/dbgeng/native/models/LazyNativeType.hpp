#pragma once

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

#include "models/IDbgEngKeyable.hpp"

namespace hxcppdbg::core::drivers::dbgeng::native::models
{
    class LazyNativeType : public IDbgEngKeyable<String, NativeNamedModelData>
    {
    private:
        std::optional<int> size;
        std::optional<Debugger::DataModel::ClientEx::Details::ObjectKeysRef<Debugger::DataModel::ClientEx::Object, Debugger::DataModel::ClientEx::Metadata>> fields;

    public:
        LazyNativeType(const Debugger::DataModel::ClientEx::Object&);

        int count();
        NativeNamedModelData at(const int);
        NativeModelData get(const String);
    };
}