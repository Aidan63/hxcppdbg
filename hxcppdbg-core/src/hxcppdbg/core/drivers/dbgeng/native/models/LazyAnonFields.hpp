#pragma once

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

#include "models/IDbgEngKeyable.hpp"

namespace hxcppdbg::core::drivers::dbgeng::native::models
{
    class LazyAnonFields : public IDbgEngKeyable<String, Dynamic>
    {
    private:
    public:
        LazyAnonFields(const Debugger::DataModel::ClientEx::Object&);

        int count();
        Dynamic at(const int);
        hxcppdbg::core::drivers::dbgeng::native::NativeModelData get(const String);
    };
}