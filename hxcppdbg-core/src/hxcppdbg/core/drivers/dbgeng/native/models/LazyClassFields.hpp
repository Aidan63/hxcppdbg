#pragma once

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

#include "models/IDbgEngKeyable.hpp"

namespace hxcppdbg::core::drivers::dbgeng::native::models
{
    class LazyClassFields : public IDbgEngKeyable<String>
    {
    private:
        Debugger::DataModel::ClientEx::Object cls;

    public:
        LazyClassFields(const Debugger::DataModel::ClientEx::Object&);

        int count();
        hxcppdbg::core::drivers::dbgeng::native::NativeModelData at(const int);
        hxcppdbg::core::drivers::dbgeng::native::NativeModelData get(const String);
    };
}