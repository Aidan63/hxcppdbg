#pragma once

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

#include "models/IDbgEngKeyable.hpp"

namespace hxcppdbg::core::drivers::dbgeng::native::models
{
    class LazyClassFields : public IDbgEngKeyable<String, NativeNamedModelData>
    {
    public:
        LazyClassFields(const Debugger::DataModel::ClientEx::Object&);

        int count();
        NativeNamedModelData at(const int);
        hxcppdbg::core::drivers::dbgeng::native::NativeModelData get(const String);
    };
}