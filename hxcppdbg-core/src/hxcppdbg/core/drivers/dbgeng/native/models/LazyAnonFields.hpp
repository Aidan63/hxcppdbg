#pragma once

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

#include "models/IDbgEngKeyable.hpp"

namespace hxcppdbg::core::drivers::dbgeng::native::models
{
    class LazyAnonFields : public IDbgEngKeyable<String>
    {
    private:
        Debugger::DataModel::ClientEx::Object anon;

    public:
        LazyAnonFields(const Debugger::DataModel::ClientEx::Object&);

        int count();
        hxcppdbg::core::drivers::dbgeng::native::NativeModelData at(const int);
        hxcppdbg::core::drivers::dbgeng::native::NativeModelData get(const String);
    };
}