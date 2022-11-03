#pragma once

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

#include "models/IDbgEngIndexable.hpp"

namespace hxcppdbg::core::drivers::dbgeng::native::models
{
    class LazyArray : public IDbgEngIndexable
    {
    private:
        Debugger::DataModel::ClientEx::Object array;

    public:
        LazyArray(const Debugger::DataModel::ClientEx::Object&);

        int count();
        hxcppdbg::core::drivers::dbgeng::native::NativeModelData at(const int);
    };
}