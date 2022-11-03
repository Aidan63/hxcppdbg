#pragma once

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

#include "models/IDbgEngIndexable.hpp"

namespace hxcppdbg::core::drivers::dbgeng::native::models
{
    class LazyEnumArguments : public IDbgEngIndexable
    {
    private:
        Debugger::DataModel::ClientEx::Object object;

    public:
        LazyEnumArguments(const Debugger::DataModel::ClientEx::Object&);

        int count();
        hxcppdbg::core::drivers::dbgeng::native::NativeModelData at(const int);
    };
}